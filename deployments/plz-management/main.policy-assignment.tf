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
    effectDiagSettings = {
      value = var.policy_diagnostics_effect # See TFVARS. 
    }
    effectAzureActivity = {
      value = var.policy_activity_effect # See TFVARS. 
    }
  })
}

# BUILT-IN: Assign built-in policy initiatives at the provided level (in the variable map, short name resolved in locals). 
resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each = {
    for k, v in var.policy_initiatives_builtin :
    k => v if v.enabled # Only select initiatives that are set to be enabled.
  }
  name                 = each.key
  display_name         = "[${upper(var.stack.naming.workload_code)}] BuiltIn - ${each.key}"
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id # Get from resolved initiative data call. 
  management_group_id  = local.management_groups_all_created.core.id             # Assign directly to core MG. 
  enforce              = each.value.enforce                                      # True/False
}
