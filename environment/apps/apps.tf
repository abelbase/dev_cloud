locals {
  location = {
    primary = "East US"
  }
  tags_addon = {
    created_by   = "terraform"
    created_date = formatdate("YYYY-MM-DD", time_static.this.rfc3339)
  }
  rules = jsondecode(file("${path.module}/../landing_zone/nsg_rules.json"))
  updated_nsg = {
    for nsg_key, nsg_value in var.vnet_detials :
    nsg_key => merge(
      nsg_value,
      {
        nsg_details = merge(
          {
            nsg_name    = nsg_value.nsg_details.nsg_name,
            subnet_name = nsg_value.nsg_details.subnet_name
          },
          {
            rule = {
              for k in nsg_value.nsg_details.all_rule :
              k => local.rules[k] if contains(keys(local.rules), k)
            }
          }

        )
      }
    )
  }

}

resource "time_static" "this" {}
module "mod_rg" {
  source      = "../../modules/resource_group"
  for_each    = { for k in var.rg : k => k }
  rg_name     = each.key
  rg_location = local.location.primary
  tags        = merge(var.tags["${each.value.rg}"], local.tags_addon)
}
module "mod_networking" {
  source             = "../../modules/networking"
  for_each           = var.vnet_detials
  rg                 = module.mod_rg["${each.value.rg}"].rg_name
  location           = local.location.primary
  vnet_name          = each.key
  vnet_address_space = each.value.vnet_address
  tags               = merge(var.tags["${each.value.rg}"], local.tags_addon)
  subnet_details     = each.value.subnet_details
  nsg_details        = each.value.nsg_details 
}
