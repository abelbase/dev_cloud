module "mod_rg" {
  source      = "../../modules/resource_group"
  rg_location = var.rg_location
  rg_name     = "${var.rg_name}-${var.app_name}-prod-rg"
  app_name    = var.app_name
  tags        = var.tags
}

module "mod_vnet" {
  source             = "../../modules/networking"
  vnet_name          = var.vnet_name
  app_name           = var.app_name
  rg                 = module.mod_rg.rg_name
  location           = module.mod_rg.rg_location
  vnet_address_space = var.vnet_address
  tags               = var.tags
  subnet_details     = var.subnet_details
  nsg_details        = var.nsg_details
}