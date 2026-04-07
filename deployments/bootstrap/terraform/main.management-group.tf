#====================================================================================#
# Bootstrap: Azure - Management Group (Core)
# Description: 
# - Deploy 'core' management group to be used for resource scopes.
# - Move all subscriptions under this new management group. 
#====================================================================================#

# Management Group: Core
resource "azurerm_management_group" "core" {
  name         = module.naming_mg[each.key].full_name                    # Use naming module to produce MG name format. 
  display_name = title(var.management_group_core[each.key].display_name) # Use map key for MG display name.   
  subscription_ids = [
    for v in data.azurerm_subscriptions.all.subscriptions : # Loop and select each subscriptions ID.
    v.subscription_id
  ]
}
