#==================================================================#
# Module: activity-log-alert
# Description: 
# - Re-usable module for creating activity log alerts. 
#==================================================================#

# Activity Log Alert
resource "azurerm_monitor_activity_log_alert" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
  scopes              = var.scopes
  description         = "Activity log alert for ${var.operation_name}"
  location            = var.location
  enabled             = var.enabled
  criteria {
    category         = var.category
    operation_name   = var.operation_name
    statuses         = var.statuses
  }
  action {
    action_group_id = var.action_group_id
  }
}
