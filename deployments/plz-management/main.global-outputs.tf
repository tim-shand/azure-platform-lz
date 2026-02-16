#====================================================================================#
# Management: Global Outputs / Shared Services
# Description: 
# - Add resource IDs and names to Global Outputs registry.  
# - These can be referenced by future deployment stacks. 
#====================================================================================#

# Logging: Log Analytics Workspace - ID
resource "azurerm_app_configuration_key" "log_law_id" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.plz_mgt_law_id # Refer to variable in globals.
  value                  = azurerm_log_analytics_workspace.mgt_logs.id
}

# Logging: Storage Account - ID
resource "azurerm_app_configuration_key" "log_sa_id" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.plz_mgt_sa_id # Refer to variable in globals.
  value                  = azurerm_storage_account.mgt_logs.id
}
