#====================================================================================#
# Governance: Management Groups
# Description: 
# - Create Management Group structure.  
# - Assign subscriptions to Management Groups.  
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mg" {
  for_each     = local.management_groups_all
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = each.key # Management Group key names. 
  stack_or_env = "mg"     # Static suffix for Management Groups. 
}

# Management Group: Core
resource "azurerm_management_group" "core" {
  for_each     = var.management_group_core
  name         = module.naming_mg[each.key].full_name                    # Use naming module to produce MG name format. 
  display_name = title(var.management_group_core[each.key].display_name) # Use map key for MG display name.   
}

# Management Groups: Level 1
resource "azurerm_management_group" "level1" {
  for_each                   = var.management_groups_level1
  name                       = module.naming_mg[each.key].full_name                              # Use naming module to produce MG name format. 
  display_name               = title(var.management_groups_level1[each.key].display_name)        # Use map key for MG display name.   
  subscription_ids           = lookup(local.management_group_subscriptions_level1, each.key, []) # Assign mapped subscriptions from locals. 
  parent_management_group_id = local.management_group_ids_level1[each.value.parent_mg_name]      # Assign to top-level MG.
}

# Management Groups: Level 2
resource "azurerm_management_group" "level2" {
  for_each                   = var.management_groups_level2
  name                       = module.naming_mg[each.key].full_name                              # Use naming module to produce MG name format.  
  display_name               = title(var.management_groups_level2[each.key].display_name)        # Use map key for MG display name.        
  subscription_ids           = lookup(local.management_group_subscriptions_level2, each.key, []) # Assign mapped subscriptions from locals. 
  parent_management_group_id = local.management_group_ids_level2[each.value.parent_mg_name]      # Assign to level 1 parent management group.
}

# Management Groups: Level 3
resource "azurerm_management_group" "level3" {
  for_each                   = var.management_groups_level3
  name                       = module.naming_mg[each.key].full_name                              # Use naming module to produce MG name format. 
  display_name               = title(var.management_groups_level3[each.key].display_name)        # Use map key for MG display name.        
  subscription_ids           = lookup(local.management_group_subscriptions_level3, each.key, []) # Assign mapped subscriptions from locals.  
  parent_management_group_id = local.management_group_ids_level3[each.value.parent_mg_name]      # Assign to level 2 parent management group.
}
