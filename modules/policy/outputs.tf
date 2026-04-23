output "policy_definition_id" {
  value = {
    for k, v in azurerm_policy_definition.this :
    k => v.id
  }
}

output "policy_set_definition_id" {
  value = {
    for k, v in azurerm_policy_set_definition.this :
    k => v.id
  }
}