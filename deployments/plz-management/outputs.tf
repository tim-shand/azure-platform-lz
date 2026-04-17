output "log_analytics_workspace" {
  description = "Object of resource properties for Log Analytics Workspace."
  value = var.enable_resource_deployment.logging ? {
    id             = try(azurerm_log_analytics_workspace.mgt[0].id, null)
    workspace_id   = try(azurerm_log_analytics_workspace.mgt[0].workspace_id, null)
    name           = try(azurerm_log_analytics_workspace.mgt[0].name, null)
    resource_group = try(azurerm_log_analytics_workspace.mgt[0].resource_group_name, null)
  } : null # Only if enabled.
}

output "storage_account" {
  description = "Object of resource properties for Storage Account."
  value = var.enable_resource_deployment.logging ? {
    id             = try(azurerm_storage_account.mgt[0].id, null)
    name           = try(azurerm_storage_account.mgt[0].name, null)
    resource_group = try(azurerm_storage_account.mgt[0].resource_group_name, null)
  } : null # Only if enabled.
}

output "mgt_action_group" {
  description = "Object of resource properties for Action Group."
  value = var.enable_resource_deployment.alerting ? {
    id             = try(azurerm_monitor_action_group.platform[0].id, null)
    name           = try(azurerm_monitor_action_group.platform[0].name, null)
    resource_group = try(azurerm_monitor_action_group.platform[0].resource_group_name, null)
    email_recipients = [
      for v in azurerm_monitor_action_group.platform[0].email_receiver : v.email_address
    ]
  } : null # Only if enabled.
}

# Entra ID Groups
output "mgt_entra_groups" {
  description = "Map of privilaged Entra ID groups."
  value = var.enable_resource_deployment.entra_id_privilaged_groups ? {
    for k, v in azuread_group.grp_adm :
    k => {
      id           = v.id
      object_id    = v.object_id
      display_name = v.display_name
      description  = v.description
    }
  } : null
}
