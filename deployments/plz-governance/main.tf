data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

data "azurerm_key_vault" "iac_kv" {
  provider            = azurerm.iac # Use aliased provider to access IaC subscription. 
  resource_group_name = ""
  name                = ""
}


output "iac_sub" {
  value = data.azurerm_subscription.iac_sub
}
