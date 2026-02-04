#=====================================================#
# Platform LZ: Governance - Policy Initiatives
#=====================================================#

locals {
  policy_initiatives_assignments = {                                                     # Create map of Initiatives, mapping to Definitions + parameters. 
    core_baseline = {                                                                    # Name of Initiative to create. 
      allowed_locations = { effect = "Audit", locations = var.policy_allowed_locations } # Provide parameters. 
      required_tag_list = { effect = "Audit", tagNames = var.policy_required_tags }
    }
    cost_controls = {
      restrict_vm_skus = { effect = "Audit", skus = var.policy_allowed_vm_skus }
    }
    decommissioned = {
      deny_all_resources = { effect = "Deny" }
    }
  }
}

# Policy: Custom Initiatives
resource "azurerm_policy_set_definition" "custom" {
  for_each     = local.policy_initiatives_assignments
  name         = "gov_initiative_${upper(each.key)}"
  display_name = "[${upper(var.naming.stack_code)}] Initiative - ${title(each.key)}"
  policy_type  = "Custom"
  dynamic "policy_definition_reference" {
    for_each = each.value
    content {
      policy_definition_id = azurerm_policy_definition.custom[policy_definition_reference.key].id
      reference_id         = policy_definition_reference.key
    }
  }
}
