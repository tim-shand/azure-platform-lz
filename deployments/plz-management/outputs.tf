# MANAGEMENT: General
# ------------------------------------------------------------- #

output "activity_log_alerts" {
  description = "Map of generated activity log alerts."
  value = {
    for k, v in azurerm_monitor_activity_log_alert.all :
    k => {
      name         = v.name
      category     = v.criteria[0].category
      action_group = v.action
    }
  }
}
