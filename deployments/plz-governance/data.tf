# IaC: Get IaC subscription for aliased provider. 
data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

# Shared Services: Get Key Vault data using alias provider. 
data "azurerm_key_vault" "iac_kv" {
  provider            = azurerm.iac                 # Use aliased provider to access IaC subscription. 
  name                = var.shared_services_kv_name # Pass in shared services Key Vault name via workflow variable. 
  resource_group_name = var.shared_services_kv_rg   # Pass in shared services Key Vault Resource Group name via workflow variable. 
}

# ------------------------------------------------------------------------------- # 

# Root Management Group: Pass in tenant ID to get root management group.
data "azurerm_management_group" "core" {
  display_name = var.management_group_core_display_name # Globals TFVARS. 
}

# Subscriptions: Collect all available subscriptions, to be nested under management groups.  
data "azurerm_subscriptions" "all" {}
