# MANAGEMENT: General
# ------------------------------------------------------------- #
locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# MANAGEMENT: Alerts
# ------------------------------------------------------------- #

# List of activity log categories to alert on. 
# locals {
#   activity_alerts = [
#     "Administrative",
#     "Policy",
#     "Security",
#     "ServiceHealth",
#     "ResourceHealth"
#   ]
# }

# # Map priority levels to actions groups. 
# locals {
#   action_group_map = {
#     P1 = azurerm_monitor_action_group.alerts_p1.id
#     P2 = azurerm_monitor_action_group.alerts_p2.id
#     P3 = azurerm_monitor_action_group.alerts_p3.id
#   }
# }

locals {
  # Map severity level to the deployed action group ID. 
  action_group_map = {
    for k, v in var.action_groups :
    k => azurerm_monitor_action_group.all[k].id
  }
}
