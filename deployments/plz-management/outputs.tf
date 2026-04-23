output "log_analytics_workspace" {
  description = "Object of resource properties for Log Analytics Workspace."
  value = {
    id             = azurerm_log_analytics_workspace.mgt.id
    workspace_id   = azurerm_log_analytics_workspace.mgt.workspace_id
    name           = azurerm_log_analytics_workspace.mgt.name
    resource_group = azurerm_log_analytics_workspace.mgt.resource_group_name
  }
}

output "storage_account" {
  description = "Object of resource properties for Storage Account."
  value = {
    id             = azurerm_storage_account.mgt.id
    name           = azurerm_storage_account.mgt.name
    resource_group = azurerm_storage_account.mgt.resource_group_name
  }
}

output "mgt_action_group" {
  description = "Object of resource properties for Action Group."
  value = azurerm_monitor_action_group.mgt
}

# Entra ID Groups
output "mgt_entra_groups" {
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

# TEMP / DEBUG ------------------------------------------------------- #

output "debug_remote_state_raw" {
  value = data.terraform_remote_state.iac.outputs.platform_subscriptions
}

output "debug_platform_subscription_ids" {
  value = local.platform_subscription_ids
}

output "debug_platform_subscriptions" {
  value = local.platform_subscriptions
}

output "debug_all_subscriptions" {
  value = [for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id]
}