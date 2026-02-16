#====================================================================================#
# Management: Global Outputs / Shared Services
# Description: 
# - Add resource IDs and names to Global Outputs registry.  
# - These can be referenced by future deployment stacks. 
#====================================================================================#

# Logging: Log Analytics Workspace
resource "azurerm_app_configuration_key" "log_law_id" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.log_analytics_workspace_id # Refer to variable in globals.
  value                  = azurerm_log_analytics_workspace.mgt_logs.id
  label                  = var.global_outputs.management.label # Related label used to identify entries. 
}
resource "azurerm_app_configuration_key" "log_law_name" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.log_analytics_workspace_name # Refer to variable in globals.
  value                  = azurerm_log_analytics_workspace.mgt_logs.name
  label                  = var.global_outputs.management.label # Related label used to identify entries. 
}
resource "azurerm_app_configuration_key" "log_law_rg" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.log_analytics_workspace_resource_group # Refer to variable in globals.
  value                  = azurerm_log_analytics_workspace.mgt_logs.resource_group_name
  label                  = var.global_outputs.management.label # Related label used to identify entries. 
}

# Logging: Storage Account
resource "azurerm_app_configuration_key" "log_sa_id" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.storage_account_id # Refer to variable in globals.
  value                  = azurerm_storage_account.mgt_logs.id
  label                  = var.global_outputs.management.label # Related label used to identify entries. 
}
resource "azurerm_app_configuration_key" "log_sa_name" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.storage_account_name # Refer to variable in globals.
  value                  = azurerm_storage_account.mgt_logs.name
  label                  = var.global_outputs.management.label # Related label used to identify entries. 
}
resource "azurerm_app_configuration_key" "log_sa_rg" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.storage_account_resource_group # Refer to variable in globals.
  value                  = azurerm_storage_account.mgt_logs.resource_group_name
  label                  = var.global_outputs.management.label # Related label used to identify entries. 
}
