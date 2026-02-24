# MANAGEMENT: General
# ------------------------------------------------------------- #
locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# List of platform subscriptions. 
locals {
  platform_subs = [
    for s in data.azurerm_subscription.platform_subs : s.id # s.subscription_id
  ]
}

# MANAGEMENT: Alerts
# ------------------------------------------------------------- #

locals {
  activity_log_alerts_merged = merge(
    azurerm_monitor_activity_log_alert.administrative,
    azurerm_monitor_activity_log_alert.policy,
    azurerm_monitor_activity_log_alert.security,
    azurerm_monitor_activity_log_alert.resource_health,
    azurerm_monitor_activity_log_alert.service_health
  )
  # Get all Action Group IDs. 
  action_group_ids = {
    for k, v in azurerm_monitor_action_group.all :
    k => v.id
  }
}

# MANAGEMENT: Entra ID Logging
# ------------------------------------------------------------- #
locals {
  entraid_log_types_enabled = {
    for k, v in var.entraid_log_types : k => v
    if v # Filter on category names that are enabled. 
  }
}
