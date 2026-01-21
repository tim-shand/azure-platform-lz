output "mg_root" {
  description = "Object of the top-level management group."
  value       = azurerm_management_group.root
}

output "mg_platform" {
  description = "Object of the platform management group."
  value       = azurerm_management_group.platform
}

output "mg_workloads" {
  description = "Object of the workloads management group."
  value       = azurerm_management_group.workloads
}

output "mg_workloads_prd" {
  description = "Object of the workloads (production) management group."
  value       = azurerm_management_group.workloads_prd
}

output "mg_workloads_dev" {
  description = "Object of the workloads (development) management group."
  value       = azurerm_management_group.workloads_dev
}

output "mg_sandbox" {
  description = "Object of the sandbox management group."
  value       = azurerm_management_group.sandbox
}

output "mg_decommissioned" {
  description = "Object of the decommissioned management group."
  value       = azurerm_management_group.decommissioned
}

output "mg_subscription_mapping" {
  description = "Object of the mapped management groups and subscriptions."
  value       = local.management_group_subscriptions
}
