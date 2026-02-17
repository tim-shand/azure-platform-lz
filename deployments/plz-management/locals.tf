# MANAGEMENT: General
# ------------------------------------------------------------- #
locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# MANAGEMENT: Alerts
# ------------------------------------------------------------- #

locals {
  # Map severity level to the deployed action group ID. 
  action_group_map = {
    for k, v in var.action_groups :
    k => azurerm_monitor_action_group.all[k].id
  }
}
