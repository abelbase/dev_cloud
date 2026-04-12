resource "azurerm_network_interface" "this" {
  name                = var.nic_details.name
  resource_group_name = var.rg
  location            = var.location
  ip_configuration {
    name                          = var.nic_details.ip_config_name
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.this[0].id, null)
    subnet_id                     = var.subnet_id
  }
}
resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.vm_name
  resource_group_name   = var.rg
  location              = var.location
  size                  = var.size
  admin_username        = var.username
  network_interface_ids = [azurerm_network_interface.this.id]
  admin_ssh_key {
    username   = var.username
    public_key = var.pub_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = var.tags
}


resource "azurerm_public_ip" "this" {
  count               = var.public_ip != null ? 1 : 0
  name                = var.public_ip["name"]
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = var.public_ip["allocation_method"]
  tags                = var.tags
}