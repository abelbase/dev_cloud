module "mod_rg" {
  source      = "git::https://github.com/abelbase/dev_cloud.git//modules/resource_group?ref=v1.0.0"
  rg_location = var.rg_location
  rg_name     = "${var.rg_name}-${var.app_name}-nonprod-rg"
  app_name    = var.app_name
  tags        = var.tags
}

module "mod_vnet" {
  source             = "git::https://github.com/abelbase/dev_cloud.git//modules/networking?ref=v1.0.0"
  vnet_name          = var.vnet_name
  app_name           = var.app_name
  rg                 = module.mod_rg.rg_name
  location           = module.mod_rg.rg_location
  vnet_address_space = var.vnet_address
  tags               = var.tags
  subnet_details     = var.subnet_details
  nsg_details        = var.nsg_details
}