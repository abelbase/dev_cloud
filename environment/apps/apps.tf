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
          nsg_value.nsg_details,
          {
            for nsg_details_key, nsg_details_value in nsg_value.nsg_details :
            nsg_details_key => merge(
              { nsg_name    = nsg_details_value.nsg_name
                subnet_name = nsg_details_value.subnet_name
              },
              {
                rule = {
                  for rule_name in nsg_details_value.all_rule :
                  rule_name => try(local.rules[rule_name], {})
                }
              }
            )
          }


        )
      }
    )
  }

}

resource "time_static" "this" {}
module "mod_rg" {
  source      = "git::https://github.com/abelbase/dev_cloud.git//modules/resource_group?ref=v1.0.4"
  for_each    = { for k in var.rg : k => k }
  rg_name     = each.key
  rg_location = local.location.primary
  tags        = merge(var.tags[each.key], local.tags_addon)
}
module "mod_networking" {
  source             = "git::https://github.com/abelbase/dev_cloud.git//modules/networking?ref=v1.0.4"
  for_each           = var.vnet_detials
  rg                 = module.mod_rg[each.value.rg].rg_name
  location           = local.location.primary
  vnet_name          = each.key
  vnet_address_space = each.value.vnet_address
  tags               = merge(var.tags[each.value.rg], local.tags_addon)
  subnet_details     = each.value.subnet_details
  nsg_details        = each.value.nsg_details
}
