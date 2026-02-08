#====================================================================================#
# Governance: Policy Initiatives
# Description: 
# - Build policy initiatives from mapped definitions. 
#====================================================================================#

# Policy: Initiatives - Add mapped definitions to each initiative. 
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
