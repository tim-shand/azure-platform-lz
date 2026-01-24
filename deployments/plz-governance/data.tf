# Data: Global Outputs - Used to stored details on global shared services. 
data "azurerm_key_vault" "globals_kv" {
  name                = var.global_outputs_kv.name
  resource_group_name = var.global_outputs_kv.resource_group
}

# Get all subscriptions visible to current identity.
data "azurerm_subscriptions" "all" {}
