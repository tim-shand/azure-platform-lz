#========================================================#
# Platform LZ: Governance - Built-in Policy Initiatives
#========================================================#

# Use provided variable value to assign a built-in policy initiative. 
data "azurerm_policy_set_definition" "builtin" {
  for_each     = var.builtin_initiatives # Loop each string value in variable to get data on policy initiative. 
  display_name = each.key
}

resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each             = data.azurerm_policy_set_definition.builtin # For each policy initiative in the data call. 
  name                 = each.key
  display_name         = "[${upper(var.naming_prefix)}] - ${each.key}"
  description          = each.value.description
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id
  management_group_id  = var.target_management_group_id # Management Group where to assign the initiative. 
  enforce              = var.enforce                    # True/False
}
