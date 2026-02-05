#====================================================================================#
# Governance: Policy Initiatives (Built-In)
# Description: 
# - Resolve and assign built-in policy initiatives.  
#====================================================================================#

# Use provided variable value to assign a built-in policy initiative. 
data "azurerm_policy_set_definition" "builtin" {
  for_each     = var.policy_initiatives_builtin # Loop each string value in variable to get data on policy initiative. 
  display_name = each.key
}

resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each             = data.azurerm_policy_set_definition.builtin # For each policy initiative in the data call. 
  name                 = each.key
  display_name         = "[${upper(var.stack.naming.workload_code)}] BuiltIn - ${each.key}"
  description          = each.value.description
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id
  management_group_id  = var.policy_initiatives_builtin[each.key].assignment_mg_id # Management Group where to assign the initiative. 
  enforce              = var.policy_initiatives_builtin[each.key].enforce          # True/False
}
