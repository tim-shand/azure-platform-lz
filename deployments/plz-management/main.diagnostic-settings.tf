#====================================================================================#
# Management: Diagnostic Settings
# Description: 
# -   
# -  
#====================================================================================#

# resource "azurerm_monitor_diagnostic_setting" "core" {
#   name                       = "diag-subscription-activity"
#   target_resource_id         = data.azurerm_app_configuration_key.mg_core
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.mgt_logs.id

#   enabled_log {
#     category = "Administrative"
#   }

#   enabled_log {
#     category = "Policy"
#   }

#   enabled_log {
#     category = "Security"
#   }

#   enabled_log {
#     category = "ServiceHealth"
#   }

#   enabled_log {
#     category = "Alert"
#   }
# }
