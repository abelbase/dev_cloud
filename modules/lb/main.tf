resource "azurerm_public_ip" "this" {
  name                = var.public_ip
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = var.allocation_method
}
resource "azurerm_lb" "this" {
  name                = var.lb_name
  resource_group_name = var.rg
  location            = var.location
  frontend_ip_configuration {
    name                 = var.lb_ip_config
    public_ip_address_id = azurerm_public_ip.this.id
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each        = var.lb_backend_pool_name
  name            = each.value.name
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  for_each                = coalesce(var.lb_backend_pool_address_name, {})
  name                    = each.value.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this[each.value.backend_pool_name].id
  virtual_network_id      = each.value.virtual_network_id
  ip_address              = each.value.ip_address
}

resource "azurerm_lb_rule" "this" {
  for_each                       = coalesce(var.lb_rule, {})
  loadbalancer_id                = azurerm_lb.this.id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = var.lb_ip_config
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.backend_pool_name].id]
  probe_id                       = azurerm_lb_probe.this[each.value.health_probe_name].id
}

resource "azurerm_lb_probe" "this" {
  for_each        = coalesce(var.lb_probe, {})
  loadbalancer_id = azurerm_lb.this.id
  name            = each.value.name
  port            = each.value.port
  protocol        = each.value.protocol
}