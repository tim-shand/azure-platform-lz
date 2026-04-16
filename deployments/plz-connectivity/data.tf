# GLOBAL / SHARED SERVICES
# ------------------------------------------------------------- #

# IaC: Get IaC subscription for aliased provider. 
data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

# Shared Services: Get App Configuration data using alias provider. 
data "azurerm_app_configuration" "iac" {
  provider            = azurerm.iac             # Use aliased provider to access IaC subscription. 
  name                = var.global_outputs_name # Pass in shared services App Configuration name via workflow variable. 
  resource_group_name = var.global_outputs_rg   # Pass in shared services App Configuration Resource Group name via workflow variable. 
}

# CONNECTIVITY: Hub VNet
# ------------------------------------------------------------- #

data "azurerm_app_configuration_key" "log_sa_id" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.storage_account_id # Refer to variable in globals.
  label                  = var.global_outputs.management.label              # Related label used to identify entries.
}

# Log Analytics
data "azurerm_app_configuration_key" "log_law_name" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.log_analytics_workspace_name # Refer to variable in globals.
  label                  = var.global_outputs.management.label                        # Related label used to identify entries.
}
data "azurerm_app_configuration_key" "log_law_rg" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.management.log_analytics_workspace_resource_group # Refer to variable in globals.
  label                  = var.global_outputs.management.label                                  # Related label used to identify entries.
}
data "azurerm_log_analytics_workspace" "log_law" {
  name                = data.azurerm_app_configuration_key.log_law_name.value
  resource_group_name = data.azurerm_app_configuration_key.log_law_rg.value
}

