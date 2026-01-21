#=============================================================#
# Platform LZ: Governance - Management Groups & Subscriptions
#=============================================================#

# Management Groups: Top-level management group for the organisation. 
resource "azurerm_management_group" "root" {
  name         = lower("${var.naming_prefix}-${var.management_group_root}") # Force lower-case, read in prefix value for resource name.
  display_name = title(var.management_group_root)                           # Enforce title-case on root MG display name. 
}

# Management Groups: Level 1
resource "azurerm_management_group" "level1" {
  for_each                   = local.management_groups_subs_level1
  name                       = lower("${var.naming_prefix}-${each.key}") # Force lower-case for resource name. 
  display_name               = title(each.value.display_name)            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.root.id          # Nested under root management group. 
  subscription_ids           = each.value.subscriptions                  # Assign mapped subscriptions. 
}

# Management Groups: Level 2
resource "azurerm_management_group" "level2" {
  for_each                   = local.management_groups_subs_level2
  name                       = lower("${var.naming_prefix}-${each.key}")                 # Force lower-case for resource name.  
  display_name               = title(each.value.display_name)                            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.level1[each.value.parent_key].id # Use string value to map to L1 MG key for nesting.  
  subscription_ids           = each.value.subscriptions                                  # Assign mapped subscriptions. 
}

# Management Groups: Level 3
resource "azurerm_management_group" "level3" {
  for_each                   = local.management_groups_subs_level3
  name                       = lower("${var.naming_prefix}-${each.key}")                 # Force lower-case for resource name.  
  display_name               = title(each.value.display_name)                            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.level2[each.value.parent_key].id # Use string value to map to L2 MG key for nesting.  
  subscription_ids           = each.value.subscriptions                                  # Assign mapped subscriptions. 
}

# Management Groups: Level 4
resource "azurerm_management_group" "level4" {
  for_each                   = local.management_groups_subs_level4
  name                       = lower("${var.naming_prefix}-${each.key}")                 # Force lower-case for resource name. 
  display_name               = title(each.value.display_name)                            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.level3[each.value.parent_key].id # Use string value to map to L3 MG key for nesting.  
  subscription_ids           = each.value.subscriptions                                  # Assign mapped subscriptions. 
}
