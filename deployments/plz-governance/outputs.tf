output "management_groups_all" {
  description = "Map of total Management Group structure."
  value       = module.management_groups.management_groups_all
}

output "policy_initiatives_builtin" {
  description = "Details of the assigned built-in Policy Initiatives."
  value = {
    for k, v in module.policy_initiatives_builtin : k => v
  }
}

output "policy_definitions" {
  description = "Map of custom Policy Definitions."
  value       = local.policy_definition_map
}

output "policy_initiatives" {
  description = "Map of custom Policy Initiatives."
  value = {
    for k, v in azurerm_policy_set_definition.custom : k => v.id
  }
}

output "policy_assignments" {
  description = "List of policy assignments with name and management group ID."
  value = [
    for assignment in azurerm_management_group_policy_assignment.custom :
    {
      name                = assignment.name
      management_group_id = assignment.management_group_id
    }
  ]
}
