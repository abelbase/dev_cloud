resource "azurerm_virtual_network" "this" {
  name                = "${var.vnet_name}${var.app_name}vnet"
  resource_group_name = var.rg
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnet_details
  name                 = "${each.key}${var.app_name}subnet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

}
resource "azurerm_network_security_group" "this" {
  for_each            = var.nsg_details
  name                = "${each.key}${var.app_name}nsg"
  resource_group_name = var.rg
  location            = var.location
  dynamic "security_rule" {
    for_each = each.value.rule
    content {
      name                       = security_rule.value.name
        priority                   = security_rule.value.priority
        direction                  = security_rule.value.direction
        access                     = security_rule.value.access
        protocol                   = security_rule.value.protocol
        source_port_range          = security_rule.value.source_port_range
        destination_port_range     = security_rule.value.destination_port_range
        source_address_prefix      = security_rule.value.source_address_prefix
        destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  depends_on          = [azurerm_virtual_network.this, azurerm_subnet.this]
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = var.nsg_details
  subnet_id                 = azurerm_subnet.this[each.value.subnet_name].id
  network_security_group_id = azurerm_network_security_group.this[each.value.nsg_name].id

}