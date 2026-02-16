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

# MANAGEMENT: General
# ------------------------------------------------------------- #

data "azurerm_app_configuration_key" "mg_core" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outptus.plz_core_mg_id
}
