#====================================================================================#
# Governance: Policy Assignments
# Description: 
# - Assign policy initiatives to Management Groups.  
#====================================================================================#

module "naming_policy_assignment" {
  for_each     = local.mg_initiative_pairs # Create name for each policy assignment. 
  source       = "../../modules/global-resource-naming"
  prefix       = "gov"
  workload     = each.value.init_name
  stack_or_env = each.value.mg_name
}

# BUILT-IN: Assign built-in policy initiatives at the provided level (in the variable map, short name resolved in locals). 
resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each = {
    for k, v in var.policy_initiatives_builtin :
    k => v if v.enabled # Only select initiatives that are set to be enabled.
  }
  name                 = each.key
  display_name         = "[${upper(var.stack.naming.workload_code)}] BuiltIn - ${each.key}"
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id # Get from resolved initiative data call. 
  management_group_id  = data.azurerm_management_group.core.id                   # Assign directly to core MG. 
  enforce              = each.value.enforce                                      # True/False
}

# Assignment: Policy Initiatives
resource "azurerm_management_group_policy_assignment" "custom" {
  for_each             = local.mg_initiative_pairs
  name                 = module.naming_policy_assignment[each.key].compact_name_unique
  management_group_id  = data.azurerm_management_group.lookup[each.value.mg_name].id
  policy_definition_id = azurerm_policy_set_definition.custom[each.value.init_name].id
  enforce              = true
  parameters = jsonencode(
    local.initiative_parameters[each.value.init_name]
  )
}
