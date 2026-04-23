resource "azurerm_kubernetes_cluster" "this" {
    for_each = var.aks_config != null ? {var.aks_config.aks_name = var.aks_config} : {}
  name = each.value.aks_name
  location = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix = each.value.dns_prefix
  default_node_pool {
    name = each.value.default_node_pool.name
    node_count = each.value.default_node_pool.node_count
    vm_size = each.value.default_node_pool.vm_size
  }
  identity {
    type ="SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_container_registry" "this" {
    for_each = var.acr_config != null ? {"${var.acr_config.name}" = var.acr_config} : {}
  name = each.value.name
  resource_group_name = each.value.resource_group_name
  location = each.value.location
  sku = each.value.sku
  tags =var.tags
}
resource "azurerm_role_assignment" "this" {
   for_each = var.acr_config != null ? {"${var.acr_config}" = var.acr_config} : {} 
  principal_id = azurerm_kubernetes_cluster.this[each.value.role_assingment].kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.this[each.key].id 
  skip_service_principal_aad_check = true
}