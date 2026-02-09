# GOVERNANCE: Management Groups
# ------------------------------------------------------------- #

output "management_groups_all" {
  description = "Full details of created Management Groups."
  value       = local.management_groups_all_created
}

# GOVERNANCE: Policy Definitions
# ------------------------------------------------------------- #

output "policy_definitions" {
  description = "Map of custom policy definitions."
  value = {
    for k, v in azurerm_policy_definition.custom :
    k => {
      display_name = v.display_name
    }
  }
}

# GOVERNANCE: Policy Initiatives
# ------------------------------------------------------------- #

# output "policies_builtin" {
#   description = "Map of built-in policy initiatives to assign."
#   value = {
#     for k, v in azurerm_management_group_policy_assignment.builtin :
#     k => {
#       display_name = v.display_name
#       mg_id        = v.management_group_id
#       enforce      = v.enforce
#     }
#   }
# }

output "policy_initiatives" {
  description = "Map of custom policy initiatives."
  value = {
    for k, v in azurerm_management_group_policy_set_definition.custom :
    k => {
      display_name = v.display_name
      name         = v.name
      policies = [
        for value in v.policy_definition_reference : value.reference_id
      ]
    }
  }
}

# GOVERNANCE: Policy Assignments
# ------------------------------------------------------------- #

# output "mg_initiatives" {
#   value = local.mg_initiative_pairs
# }

# output "mg_initiatives" {
#   value = local.mg_initiatives
# }

# output "mg_initiatives" {
#   value = local.mg_with_initiatives
# }

# output "policy_assignments" {
#   value = azurerm_management_group_policy_assignment.custom
# }

# output "mg_policy_sets" {
#   value = azurerm_management_group_policy_set_definition.custom
# }
