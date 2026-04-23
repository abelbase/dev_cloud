output "vnet_detials" {
  description = "Virtual network details"
  value = {
    for k, v in module.mod_networking.vnet_id :
    k => v.id
  }
}