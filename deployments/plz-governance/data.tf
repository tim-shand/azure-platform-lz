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

# Root Management Group: Pass in tenant ID to get root management group.
data "azurerm_management_group" "root" {
  name = data.azuread_client_config.current.tenant_id
}

# Get creatednames for all MGs. 
# data "azurerm_management_group" "lookup" {
#   for_each     = local.management_groups_all
#   display_name = each.value.display_name
# }

# Subscriptions: Collect all available subscriptions, to be nested under management groups.  
data "azurerm_subscriptions" "all" {}


# GOVERNANCE: Policy and Initiatives (Built-In)
# ------------------------------------------------------------- #

# Use provided variable value to assign a built-in policy initiative. 
data "azurerm_policy_set_definition" "builtin" {
  for_each = {
    for k, v in var.policy_initiatives_builtin :
    k => v if v.enabled # Only select initiatives that are set to be enabled. 
  }
  name = each.value.definition_id # Name equals GUID for built-in initiatives. 
}
