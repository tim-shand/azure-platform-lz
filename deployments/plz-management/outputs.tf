# MANAGEMENT: General
# ------------------------------------------------------------- #

# output "activity_log_alerts" {
#   description = "Map of generated activity log alerts."
#   value = {
#     #for k, v in azurerm_monitor_activity_log_alert.all :
#     for k, v in local.activity_log_alerts_merged :
#     k => {
#       name         = v.name
#       category     = v.criteria[0].category
#       action_group = v.action
#     }
#   }
# }

output "activity_log_alerts_merged" {
  description = "Merged map of activity log alert rules."
  value       = local.activity_log_alerts_merged
}

# output "test" {
#   value = local.activity_log_alerts_action_groups
# }

