#====================================================================================#
# Governance: Policy Initiatives (Built-In)
# Description: 
# - Resolve and assign built-in policy initiatives.  
#====================================================================================#

# BUILT-IN: Assign built-in policy initiatives at the provided level (in the variable map, short name resolved in locals). 
resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each = {
    for k, v in var.policy_initiatives_builtin :
    k => v if v.enabled # Only select initiatives that are set to be enabled.
  }
  name                 = each.key
  display_name         = "[${upper(var.stack.naming.workload_code)}] BuiltIn - ${each.key}"
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id # Get from resolved initiative data call. 
  management_group_id = local.management_group_registry[                         # Use registry to flatten all MGs and provide list of names to assign to. 
    try(each.value.assignment_mg_id, "core")                                     # Try get result from value, else use 'core' as default. 
  ]
  enforce = each.value.enforce # True/False
}

# CUSTOM: Custom Initiatives. 
resource "azurerm_policy_set_definition" "custom" {
  for_each     = var.policy_initiatives # Governance TFVARS
  name         = "gov_initiative_custom_${upper(each.key)}"
  display_name = "[${upper(var.stack.naming.workload_code)}] Initiative - ${title(replace(each.key, "_", " "))}"
  policy_type  = "Custom"
  dynamic "policy_definition_reference" {
    for_each = each.value
    content {
      policy_definition_id = azurerm_policy_definition.custom[policy_definition_reference.value].id
      reference_id         = replace(lower(policy_definition_reference.value), "_", "-")
      parameter_values = jsonencode({
        allowed_locations = contains(each.value, "allowed_locations") ? var.policy_var_allowed_locations : null # Only pass parameters if relevant. 
        required_tags     = contains(each.value, "required_tag_list") ? var.policy_var_required_tags : null     # Only pass parameters if relevant. 
        allowed_vm_skus   = contains(each.value, "restrict_vm_skus") ? var.policy_var_allowed_vm_skus : null    # Only pass parameters if relevant. 
        # Effect is applied at assignment, not in the initiative definition.
      })
    }
  }
}
