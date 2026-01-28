#================================================================================#
# Bootstrap: Azure - Main
# Description: 
# - Creates top-level (core) Management Group.
# - Configure locals and data resources. 
#================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mg_core" {
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = var.management_group_core_id
  stack_or_env = "mg"
}

# Management Group: Core (Top-Level) - Group organisation child management groups. 
resource "azurerm_management_group" "core" {
  name         = module.naming_mg_core.full_name
  display_name = var.management_group_core_display_name
  subscription_ids = [
    for s in data.azurerm_subscriptions.all.subscriptions : # Move ALL existing subscriptions under the core management group. 
    s.subscription_id                                       # Required to enable subscriptions to inherit RBAC for SP.
  ]
}
