data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

data "azurerm_key_vault" "iac_kv" {
  provider            = azurerm.iac                 # Use aliased provider to access IaC subscription. 
  name                = var.shared_services_kv_name # Pass in shared services Key Vault name via workflow variable.
  resource_group_name = var.shared_services_kv_rg   # Pass in shared services Key Vault Resource Group name via workflow variable. 
}


output "iac_sub" {
  value = data.azurerm_subscription.iac_sub
}

output "iac_kv" {
  value = data.azurerm_key_vault.iac_kv
}
