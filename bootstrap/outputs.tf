output "management_group_core_id" {
  description = "ID of the core management group."
  value       = azurerm_management_group.core.id
}

output "management_group_core_display_name" {
  description = "Display name of the core management group."
  value       = azurerm_management_group.core.display_name
}

output "deployments" {
  description = "Map of environment configuration to deploy."
  value       = local.deployment_configs
}
