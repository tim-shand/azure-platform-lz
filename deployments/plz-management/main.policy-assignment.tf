#====================================================================================#
# Management: Policy Assignments (Logging, Diagnostics)
# Description: 
# - Assign policy initiative to deploy logging and diagnostic settings. 
#====================================================================================#

# Policy Assignment: Resource Category Logging
resource "azurerm_management_group_policy_assignment" "activity_logs" {
  name                 = "${var.stack.naming.workload_code}-resource-logging"
  display_name         = "[${upper(var.stack.naming.workload_code)}] - Enable Resource Logging to Log Analytics (Supported Resources)"
  description          = "[${title(var.stack.naming.workload_name)}]: Deploy resource logging policy initiative for monitoring."
  policy_definition_id = data.azurerm_policy_set_definition.policy_diag_plz.id
  management_group_id  = data.azurerm_app_configuration_key.mg_platform_id.value
  location             = data.azurerm_user_assigned_identity.policy_mi.location # MUST be used when assigning with Managed Identity. 
  identity {
    type         = "UserAssigned"                                     # Alt. System-Assigned
    identity_ids = [data.azurerm_user_assigned_identity.policy_mi.id] # Use managed identity from Governance stack. 
  }
  parameters = jsonencode({
    logAnalytics = {
      value = azurerm_log_analytics_workspace.mgt_logs.id
    }
    diagnosticSettingName = {
      value = "${var.stack.naming.workload_code}-deployed-by-policy"
    }
    effect = {
      value = var.policy_diagnostics_effect # See TFVARS. 
    }
  })
}

