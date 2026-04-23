#==============================================================================================#
# Bootstrap: Azure - Management Group: Core
# Description: 
# - Creates top-level management group representing organization.
#==============================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mg" {
  for_each      = var.management_group_core
  source        = "../../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = each.key
}

# Management Group: Core
resource "azurerm_management_group" "core" {
  for_each     = var.management_group_core
  name         = module.naming_mg[each.key].management_group              # Use naming module to produce MG name format. 
  display_name = title(var.management_group_core[each.key].display_name)  # Use map key for MG display name.
  subscription_ids = [ # Add ALL accessible subscriptions under this core management group.
    for sub in data.azurerm_subscriptions.all.subscriptions : 
    sub.subscription_id
  ]
}
