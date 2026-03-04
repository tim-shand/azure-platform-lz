#====================================================================================#
# Management: Microsoft Defender for Cloud
# Description: 
# - Configure settings for MDFC.    
#====================================================================================#

# Enable logging to Log Analytics. 
resource "azurerm_security_center_workspace" "mdfc" {
  scope        = data.azurerm_app_configuration_key.mg_core_id.value
  workspace_id = azurerm_log_analytics_workspace.mgt_logs.id
}

# Alerts: Send to contact.
resource "azurerm_security_center_contact" "mdfc" {
  name                = "SecurityTeam"
  email               = var.action_groups.security.email_address[0]
  alert_notifications = true  # Send security alerts notifications to the security contact.
  alerts_to_admins    = false # Send security alerts notifications to subscription admins.
}
