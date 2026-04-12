output "all_out_pub" {
  value = azurerm_public_ip.this
}
output "all_out_nic" {
  value = azurerm_network_interface.this
}
output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}