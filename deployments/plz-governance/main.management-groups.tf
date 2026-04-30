#====================================================================================#
# Governance: Management Groups
# Description: 
# - Create Management Group structure.  
# - Assign subscriptions to Management Groups.  
#====================================================================================#

module "naming_mg" {
  for_each     = local.management_groups_all
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = each.key # Management Group key names.
}

# Management Groups: Level 1
resource "azurerm_management_group" "level1" {
  for_each                   = var.management_groups_level1
  name                       = module.naming_mg[each.key].management_group                       # Use naming module to produce MG name format. 
  display_name               = title(var.management_groups_level1[each.key].display_name)        # Use map key for MG display name.   
  subscription_ids           = lookup(local.management_group_subscriptions_level1, each.key, []) # Assign mapped subscriptions from locals. 
  parent_management_group_id = data.azurerm_management_group.core.id                             # Use 'core' MG.
}

# Management Groups: Level 2
resource "azurerm_management_group" "level2" {
  for_each                   = var.management_groups_level2
  name                       = module.naming_mg[each.key].management_group  
  display_name               = title(var.management_groups_level2[each.key].display_name)        
  subscription_ids           = lookup(local.management_group_subscriptions_level2, each.key, []) 
  parent_management_group_id = local.management_group_ids_level2[each.value.parent_mg_name]
}

# Management Groups: Level 3
resource "azurerm_management_group" "level3" {
  for_each                   = var.management_groups_level3
  name                       = module.naming_mg[each.key].management_group
  display_name               = title(var.management_groups_level3[each.key].display_name)        
  subscription_ids           = lookup(local.management_group_subscriptions_level3, each.key, [])  
  parent_management_group_id = local.management_group_ids_level3[each.value.parent_mg_name]
}
