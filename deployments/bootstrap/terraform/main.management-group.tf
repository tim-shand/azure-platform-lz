#====================================================================================#
# Bootstrap: Azure - Management Group (Core)
# Description: 
# - Deploy 'core' management group to be used for resource scopes.
# - Move all subscriptions under this new management group. 
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mg_core" {
  source   = "../../../modules/global-resource-naming"
  prefix   = var.global.naming.org_prefix
  workload = var.management_group_core.short_name
}

# Management Group: Core
resource "azurerm_management_group" "core" {
  name         = module.naming_mg_core.management_group # Use naming module to produce MG name format. 
  display_name = title(var.management_group_core.display_name)
  subscription_ids = [
    for v in data.azurerm_subscriptions.all.subscriptions : # Loop and select each subscriptions ID.
    v.subscription_id
  ]
}
