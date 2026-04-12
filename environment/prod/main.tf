locals {
  tags = merge(
    var.tags,
    {
      created_date = formatdate("YYYY-MM-DD", time_static.this.rfc3339)
    }
  )
}

module "mod_rg" {
  source      = "git::https://github.com/abelbase/dev_cloud.git//modules/resource_group?ref=v1.0.0"
  rg_location = var.rg_location
  rg_name     = "${var.rg_name}-${var.app_name}-prod-rg"
  app_name    = var.app_name
  tags        = local.tags
}

module "mod_vnet" {
  source             = "git::https://github.com/abelbase/dev_cloud.git//modules/networking?ref=v1.0.0"
  vnet_name          = var.vnet_name
  app_name           = var.app_name
  rg                 = module.mod_rg.rg_name
  location           = module.mod_rg.rg_location
  vnet_address_space = var.vnet_address
  tags               = local.tags
  subnet_details     = var.subnet_details
  nsg_details        = var.nsg_details
}
data "azurerm_key_vault" "main" {
  name                = var.vault_name
  resource_group_name = var.vault_rg
}
data "azurerm_key_vault_secret" "keys" {
  name         = var.vault_secret
  key_vault_id = data.azurerm_key_vault.main.id
}
module "mod_vm" {
  source      = "../../modules/compute"
  for_each    = var.vm_name
  nic_details = each.value.nic
  rg          = module.mod_rg.rg_name
  location    = module.mod_rg.rg_location
  vm_name     = each.key
  size        = var.size
  username    = var.username
  public_ip   = each.value.is_public ? lookup(var.public_ip, each.key, null) : null
  tags        = local.tags
  pub_key     = data.azurerm_key_vault_secret.keys.value
  subnet_id   = lookup(module.mod_vnet.sunet_id, each.value.subnet_name, null) != null ? module.mod_vnet.sunet_id[each.value.subnet_name] : null
}

resource "azurerm_virtual_machine_extension" "customScript" {
  for_each             = var.vm_extension
  name                 = each.key
  virtual_machine_id   = module.mod_vm[each.value.vm_name].vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = jsonencode({
    commandToExecute = file("${path.module}/${each.value.script_name}")
  })
  tags = local.tags
}
resource "time_static" "this" {

}

