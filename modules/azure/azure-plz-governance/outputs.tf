output "gov_management_group_subscriptions" {
  description = "List of management groups and associated subscriptions."
  value       = azurerm_management_group.plz_governance_mg
}
