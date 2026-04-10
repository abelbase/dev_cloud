output "vnet_name" {
  value = azurerm_virtual_network.this.name
}
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "sunet_id" {
  value = {
    for name, subnet in azurerm_subnet.this :
    name => subnet.id
  }
}