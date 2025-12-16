output "plz_governance_mg_root" {
  description = "Name ID of the top-level management group."
  value       = azurerm_management_group.plz_governance_mg_root.id
}

output "plz_governance_mg" {
  description = "List of management groups and associated subscriptions."
  value       = azurerm_management_group.plz_governance_mg
}
