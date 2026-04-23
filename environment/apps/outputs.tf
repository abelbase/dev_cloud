output "vnet_detials" {
  description = "Virtual network details"
  value = {
    for k, v in module.mod_networking :
    k => v.vnet_id
  }
}
output "nsg_details" {
  value = local.updated_nsg
}