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

# GOVERNANCE: Management Groups
# ------------------------------------------------------------- #

# Subscriptions: Collect all available subscriptions, to be nested under management groups.  
data "azurerm_subscriptions" "all" {}

# Management Group: Core MG ID/name.  
data "azurerm_app_configuration_key" "mg_core_id" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.core_mg_id
  label                  = var.global_outputs.governance.label
}
data "azurerm_app_configuration_key" "mg_core_name" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.core_mg_name
  label                  = var.global_outputs.governance.label
}

# Get created names for all MGs. 
data "azurerm_management_group" "lookup" {
  for_each     = local.management_groups_all_created
  display_name = each.value.display_name
  depends_on = [
    azurerm_management_group.level1,
    azurerm_management_group.level2,
    azurerm_management_group.level3
  ]
}

# GOVERNANCE: Policy Initiative (Built-in)
data "azurerm_policy_set_definition" "builtin" {
  for_each     = var.policy_initiatives_builtin # Resolve name of each initiative to ID. 
  display_name = each.key
}
