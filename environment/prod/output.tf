output "subnets" {
  value = module.mod_vnet.sunet_id
}
output "pub" {
  value = {
    for k, v in module.mod_vm :
    k => v.all_out_pub
  }
}
output "nic" {
  value = {
    for k, v in module.mod_vm :
    k => v.all_out_nic
  }
}

output "vm_details" {
  value = {
    for k, v in module.mod_vm :
    k => v.vm.private_ip_address
  }
}
output "backend_pool" {
  value = local.backend_pool
}