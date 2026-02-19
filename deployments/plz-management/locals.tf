# MANAGEMENT: General
# ------------------------------------------------------------- #
locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# MANAGEMENT: Alerts
# ------------------------------------------------------------- #

# Map severity level to the deployed action group ID. 
locals {
  action_group_map = {
    for k, v in var.action_groups :
    k => azurerm_monitor_action_group.all[k].id
  }
}

# List of platform subscriptions. 
locals {
  platform_subs = [
    for s in data.azurerm_subscription.platform_subs : s.id # s.subscription_id
  ]
}
