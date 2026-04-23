locals {
  environment = {
    "prod" = {
      primary = "East US"
    }
  }
  tag_addon = {
    created_by   = "terraform"
    created_date = formatdate("YYYY-MM-DD", time_static.this.rfc3339)
  }
  policy_config = jsondecode(file("${path.module}/policy.json"))
  rules         = jsondecode(file("${path.module}/nsg_rules.json"))
  updated_nsg_details = {
    for nsg_key, nsg_value in var.nsg_details :
    nsg_key => merge(
      { nsg_name = nsg_value.nsg_name
      subnet_name = nsg_value.subnet_name },
      {
        rule = { for k in nsg_value.all_rule :
          k => local.rules[k] if contains(keys(local.rules), k)
        }
      }
    )
  }
}
resource "time_static" "this" {}
module "mod_resource_group" {
  source      = "git::https://github.com/abelbase/dev_cloud.git//modules/resource_group?ref=v1.0.4"
  for_each    = var.rg_config
  rg_name     = "${each.key}-${each.value.tags.team}-rg"
  rg_location = local.environment.prod.primary
  tags        = merge(each.value.tags, local.tag_addon)
}

module "mod_policy" {
  source            = "git::https://github.com/abelbase/dev_cloud.git//modules/policy?ref=v1.0.4"
  policy_config     = local.policy_config
  policy_set_config = var.policy_set_config
}
data "azurerm_subscription" "current" {}
resource "azurerm_subscription_policy_assignment" "this" {
  name                 = "goverancePolicyAssigment"
  policy_definition_id = module.mod_policy.policy_set_definition_id["goverancepolicy"]
  subscription_id      = data.azurerm_subscription.current.id
}

module "mod_landing_networking" {
  source             = "git::https://github.com/abelbase/dev_cloud.git//modules/networking?ref=v1.0.4"
  vnet_name          = var.vnet_name
  rg                 = module.mod_resource_group["landingzone"].rg_name
  location           = local.environment.prod.primary
  vnet_address_space = var.vnet_address_space
  tags               = merge(var.tags, local.tag_addon)
  subnet_details     = var.subnet_details
  nsg_details        = local.updated_nsg_details
}
resource "azurerm_nat_gateway" "this" {
  name                = var.nat_gateway_name
  resource_group_name = module.mod_resource_group["landingzone"].rg_name
  location            = local.environment.prod.primary
  sku_name            = "Standard"
  tags                = merge(var.tags, local.tag_addon)
}
resource "azurerm_public_ip" "this" {
  name                = "natgatewayip"
  resource_group_name = module.mod_resource_group["landingzone"].rg_name
  location            = local.environment.prod.primary
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = merge(var.tags, local.tag_addon)

}
resource "azurerm_nat_gateway_public_ip_association" "this" {
  public_ip_address_id = azurerm_public_ip.this.id
  nat_gateway_id       = azurerm_nat_gateway.this.id
}
resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = module.mod_landing_networking.sunet_id["ManagementSubnet"]
  nat_gateway_id = azurerm_nat_gateway.this.id
}
resource "azurerm_bastion_host" "this" {
  name                = "bastionHUB"
  resource_group_name = module.mod_resource_group["landingzone"].rg_name
  location            = local.environment.prod.primary
  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.mod_landing_networking.sunet_id["AzureBastionSubnet"]
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
  tags = merge(var.tags, local.tag_addon)
}
resource "azurerm_public_ip" "bastion" {
  name                = "bastionip"
  resource_group_name = module.mod_resource_group["landingzone"].rg_name
  location            = local.environment.prod.primary
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = merge(var.tags, local.tag_addon)
}