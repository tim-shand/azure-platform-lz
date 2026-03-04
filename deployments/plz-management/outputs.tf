# MANAGEMENT: General
# ------------------------------------------------------------- #

# Log Analytics Workspace
output "mgt_law_name" {
  description = "Log Analytics Workspace name."
  value       = azurerm_log_analytics_workspace.mgt_logs.name
}
output "mgt_law_rg" {
  description = "Log Analytics Workspace resource group."
  value       = azurerm_log_analytics_workspace.mgt_logs.resource_group_name
}
