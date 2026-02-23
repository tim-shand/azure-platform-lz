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
}

# locals {
#   activity_log_alerts_action_groups = {
#     for k, v in var.action_groups :
#     k => {
#       for k, v in var.activity_log_alerts :
#       k => {
#         action_group = azurerm_monitor_action_group.all[k].name
#       }
#     }
#   }
# }

locals {
  # Get all Action Group IDs. 
  action_group_ids = {
    for k, v in azurerm_monitor_action_group.all :
    k => v.id
  }
  # Map them Action Group IDs to Alerts. 
  # activity_log_alerts_resolved = {
  #   for name, alert in var.activity_log_alerts :
  #   name => merge(alert, {
  #     action_group_id = azurerm_monitor_action_group.all[alert.action_group].id
  #   })
  # }
}

# locals {
#   action_group_alerts_map = {
#     for k, v in var.action_groups : # k="platform", "security"
#     k => azurerm_monitor_action_group.all[k].id
#   }
# }
