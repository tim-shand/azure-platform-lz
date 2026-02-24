#====================================================================================#
# Management: Diagnostic Settings (Entra ID)
# Description: 
# - Configure Entra ID activity logging to Log Analytics. 
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting
#====================================================================================#

# Diagnostic Settings: Entra ID - Logging
resource "azurerm_monitor_aad_diagnostic_setting" "main" {
  name                       = "mgt-diag-entra-logs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.mgt_logs.id
  dynamic "enabled_log" {
    for_each = local.entraid_log_types_enabled # Loop dynamic for each enabled category log type. 
    content {
      category = enabled_log.key # Must use name of dynamic object as the "each". 
    }
  }
}
