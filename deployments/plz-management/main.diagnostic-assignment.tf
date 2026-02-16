#====================================================================================#
# Management: Diagnostic Settings - Apply via Policy
# Description: 
# - Assign policy initiative to deploy diagnostic settings. 
#====================================================================================#

# Policy Assignment: Diagnostic Settings
resource "azurerm_management_group_policy_assignment" "diag" {
  name                 = "${var.stack.naming.stack_code}-deploy-diagnostics"
  display_name         = "${upper(var.stack.naming.stack_code)} - Deploy Diagnostic Settings"
  location             = var.global.location.primary # REQUIRED when using managed identity. 
  policy_definition_id = data.azurerm_policy_set_definition.policy_diag_plz_name.id
  management_group_id  = data.azurerm_app_configuration_key.mg_platform_id
  identity {
    type         = "UserAssigned"                        # Alt. System-Assigned
    identity_ids = [azurerm_user_assigned_identity.diag] # Use created managed identity. 
  }
  parameters = jsonencode({
    logAnalyticsWorkspaceId = {
      value = azurerm_log_analytics_workspace.mgt_logs.id
    }
    diagnosticSettingName = {
      value = "${var.stack.naming.stack_code}-deployed-by-policy"
    }
    effect = {
      value = var.policy_diagnostics_mode # See TFVARS. 
    }
  })
}
