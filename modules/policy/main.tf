resource "azurerm_policy_definition" "this" {
  for_each     = var.policy_config
  name         = each.key
  policy_type  = each.value.policy_type
  mode         = each.value.mode
  display_name = each.value.display_name
  policy_rule  = jsonencode(each.value.policy_rule)
}

resource "azurerm_policy_set_definition" "this" {
  for_each     = var.policy_set_config
  name         = each.key
  policy_type  = each.value.policy_type
  display_name = each.value.display_name
  dynamic "policy_definition_reference" {
    for_each = { for v in each.value.set_definition : v => v }
    content {
      policy_definition_id = azurerm_policy_definition.this[policy_definition_reference.key].id
    }
  }
}