output "management_group_core_id" {
  description = "ID of the core management group."
  value       = azurerm_management_group.core.id
}

output "management_group_core_display_name" {
  description = "Display name of the core management group."
  value       = azurerm_management_group.core.display_name
}

output "stack_subscriptions" {
  description = "Map of platform subscriptions and associated deployment stacks."
  value       = local.stack_subscriptions
}
