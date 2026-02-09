#====================================================================================#
# Governance: Policy Assignments
# Description: 
# - Assign policy initiatives to Management Groups.  
# - Definition -> Initiative -> Assignment -> Scope
#====================================================================================#

# # BUILT-IN: Assign built-in policy initiatives at the provided level (in the variable map, short name resolved in locals). 
# resource "azurerm_management_group_policy_assignment" "builtin" {
#   for_each = {
#     for k, v in var.policy_initiatives_builtin :
#     k => v if v.enabled # Only select initiatives that are set to be enabled.
#   }
#   name                 = each.key
#   display_name         = "[${upper(var.stack.naming.workload_code)}] BuiltIn - ${each.key}"
#   policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id # Get from resolved initiative data call. 
#   management_group_id  = local.management_groups_all_created.core.id             # Assign directly to core MG. 
#   enforce              = each.value.enforce                                      # True/False
# }

# # CUSTOM: Assign Policy Definitions to mapped Management Groups. 

# resource "azurerm_management_group_policy_assignment" "custom" {
#   for_each = {
#     for a in local.initiative_assignments : "${a.mg}-${a.initiative}" => a
#   }
#   name                 = "assign-${each.value.initiative}"
#   policy_definition_id = azurerm_management_group_policy_set_definition.custom[each.value.initiative].id
#   management_group_id  = data.azurerm_management_group.lookup[each.value.mg].id
# }
