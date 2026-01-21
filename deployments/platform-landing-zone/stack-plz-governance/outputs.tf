output "mg_root" {
  description = "Name ID of the top-level management group."
  value       = module.gov_management_groups.mg_root
}

output "mg_subscription_mapping" {
  description = "Object of the mapped management groups and subscriptions."
  value       = module.gov_management_groups.mg_subscription_mapping
}

output "policy_builtin_assignment" {
  description = "List of assigned built-in policy initiatives."
  value       = module.gov_policy_initiatives_builtin[0].configuration
}

output "policy_definitions_custom" {
  description = "List of custom policy definitions."
  value       = module.gov_policy_definitions_custom.policies
}

output "policy_initiatives_custom" {
  description = "Map of custom policy initiative names and IDs."
  value       = module.gov_policy_initiatives_custom.initiatives
}
