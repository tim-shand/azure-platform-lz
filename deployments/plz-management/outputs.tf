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

# Entra ID Groups
output "azuread_groups_adm" {
  description = "Map of privilaged Entra ID groups."
  value = {
    for k, v in azuread_group.grp_adm :
    k => {
      id           = v.id
      object_id    = v.object_id
      display_name = v.display_name
      description  = v.description
    }
  }
}
