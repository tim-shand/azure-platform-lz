#====================================================================================#
# Management: Diagnostic Settings - Apply via Policy
# Description: 
# - Assign policy initiative to deploy diagnostic settings. 
#====================================================================================#

# Policy Assignment: Diagnostic Settings
resource "azurerm_management_group_policy_assignment" "diag" {
  name                 = "${var.stack.naming.workload_code}-deploy-diagnostics"
  display_name         = "[${upper(var.stack.naming.workload_code)}] - Deploy Diagnostic Settings"
  description          = "[${title(var.stack.naming.workload_name)}]: Deploy platform diagnostics policy initiative for monitoring."
  location             = var.global.location.primary # REQUIRED when using managed identity. 
  policy_definition_id = data.azurerm_policy_set_definition.policy_diag_plz.id
  management_group_id  = data.azurerm_app_configuration_key.mg_platform_id.value
  identity {
    type         = "UserAssigned"                           # Alt. System-Assigned
    identity_ids = [azurerm_user_assigned_identity.diag.id] # Use created managed identity. 
  }
  parameters = jsonencode({
    logAnalyticsWorkspaceId = {
      value = azurerm_log_analytics_workspace.mgt_logs.id
    }
    diagnosticSettingName = {
      value = "${var.stack.naming.workload_code}-deployed-by-policy"
    }
    effect = {
      value = var.policy_diagnostics_mode # See TFVARS. 
    }
  })
}
