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

# Management Group: Core MG ID - used for Managed Identity RBAC scope. 
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

# Management Group: Platform MG ID - used for assigning diagnostics policy.  
data "azurerm_app_configuration_key" "mg_platform_id" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.platform_mg_id
  label                  = var.global_outputs.governance.label
}

# Policy Diagnostics (Platform) - Used for assignment after LAW deployment. 
data "azurerm_app_configuration_key" "policy_diag_plz_name" {
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.policy_diag_plz_name
  label                  = var.global_outputs.governance.label
}
data "azurerm_policy_set_definition" "policy_diag_plz" {
  name                  = data.azurerm_app_configuration_key.policy_diag_plz_name.value
  management_group_name = data.azurerm_app_configuration_key.mg_core_name.value
}

# MANAGEMENT: Subscriptions
# ------------------------------------------------------------- #

# Subscription IDs (Platform)
data "azurerm_app_configuration_key" "platform_subs" {
  for_each               = var.global_outputs.subscriptions # Loop for each entry in subscription keys list. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = each.value
  label                  = var.global_outputs.iac.label
}

# Subscriptions Details (Platform)
data "azurerm_subscription" "platform_subs" {
  for_each        = data.azurerm_app_configuration_key.platform_subs
  subscription_id = each.value.value
}

# MANAGEMENTE: Policy and Initiatives (Built-In)
# ------------------------------------------------------------- #

# Use provided variable value to assign a built-in policy initiative. 
data "azurerm_policy_set_definition" "builtin" {
  for_each = {
    for k, v in var.policy_initiatives_builtin :
    k => v if v.enabled # Only select initiatives that are set to be enabled. 
  }
  name = each.value.definition_id # Name equals GUID for built-in initiatives. 
}
