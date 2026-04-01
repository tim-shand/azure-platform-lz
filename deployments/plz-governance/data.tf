# GLOBAL / SHARED SERVICES
# ------------------------------------------------------------- #

# IaC: Get IaC subscription for aliased provider. 
data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

# IaC: Get core management group from bootstrap state.
data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"
  config = {
    resource_group_name  = "${var.remote_state_bootstrap.resource_group}"
    storage_account_name = "${var.remote_state_bootstrap.storage_account}"
    container_name       = "${var.remote_state_bootstrap.blob_container}"
    key                  = "${var.remote_state_bootstrap.state_key}"
  }
}

# GOVERNANCE: Management Groups
# ------------------------------------------------------------- #

# Subscriptions: Collect all available subscriptions, to be nested under management groups.  
data "azurerm_subscriptions" "all" {}

# Policy Initiative (Built-in)
data "azurerm_policy_set_definition" "builtin" {
  for_each     = var.policy_initiatives_builtin # Resolve name of each initiative to ID. 
  display_name = each.key
}

#data.azurerm_management_group.lookup
data "azurerm_management_group" "lookup" {
  for_each     = local.management_groups_all
  display_name = each.value.display_name
  depends_on = [
    azurerm_management_group.core,
    azurerm_management_group.level1,
    azurerm_management_group.level2,
    azurerm_management_group.level3
  ]
}
