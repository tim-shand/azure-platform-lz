# Shared Services: Get App Configuration data using alias provider. 
data "azurerm_app_configuration" "iac" {
  provider            = azurerm.iac              # Use aliased provider to access IaC subscription. 
  name                = var.shared_services_name # Pass in shared services App Configuration name via workflow variable. 
  resource_group_name = var.shared_services_rg   # Pass in shared services App Configuration Resource Group name via workflow variable. 
}

# Shared Services: Get App Configuration key: Management Group (Core). 
data "azurerm_app_configuration_key" "mg_core" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.shared_services.plz_gov_mg_core # Refer to variable in globals. 
  label                  = var.stack.naming.workload_name      # REQUIRED: Fails lookup without this, if it is set at resource. 
}

# ------------------------------------------------------------------------------- # 

# IaC: Get IaC subscription for aliased provider. 
data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

# Root Management Group: Pass in tenant ID to get root management group.
data "azurerm_management_group" "core" {
  name = data.azurerm_app_configuration_key.mg_core.value
}

# Subscriptions: Collect all available subscriptions, to be nested under management groups.  
data "azurerm_subscriptions" "all" {}
