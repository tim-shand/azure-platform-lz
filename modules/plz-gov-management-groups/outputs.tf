output "mg_root" {
  description = "Name ID of the top-level management group."
  value       = azurerm_management_group.mg_root
}

output "mg_child" {
  description = "List of Management Groups and subscription associations."
  value       = azurerm_management_group.mg_child #local.mg_subscription_ids
}
