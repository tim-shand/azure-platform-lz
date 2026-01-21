locals {
  # Map matching subscriptions to management groups based on first three segments of the subscription ID. 
  management_groups_subs_level1 = {
    for mg, details in var.management_groups_level1 :
    mg => {
      display_name = details.display_name
      subscriptions = [
        for sub in var.subscriptions : sub.subscription_id
        if contains(details.subscription_id_filter, join("-", slice(split("-", sub.subscription_id), 0, 3)))
      ]
    }
  }
  management_groups_subs_level2 = {
    for mg, details in var.management_groups_level2 :
    mg => {
      display_name = details.display_name
      parent_key   = details.parent_mg_name # Map static 'parent_mg_name' value to L1 MG key. 
      subscriptions = [
        for sub in var.subscriptions : sub.subscription_id
        if contains(details.subscription_id_filter, join("-", slice(split("-", sub.subscription_id), 0, 3)))
      ]
    }
  }
  management_groups_subs_level3 = {
    for mg, details in var.management_groups_level3 :
    mg => {
      display_name = details.display_name
      parent_key   = details.parent_mg_name # Map static 'parent_mg_name' value to L2 MG key. 
      subscriptions = [
        for sub in var.subscriptions : sub.subscription_id
        if contains(details.subscription_id_filter, join("-", slice(split("-", sub.subscription_id), 0, 3)))
      ]
    }
  }
  management_groups_subs_level4 = {
    for mg, details in var.management_groups_level4 :
    mg => {
      display_name = details.display_name
      parent_key   = details.parent_mg_name # Map static 'parent_mg_name' value to L3 MG key. 
      subscriptions = [
        for sub in var.subscriptions : sub.subscription_id
        if contains(details.subscription_id_filter, join("-", slice(split("-", sub.subscription_id), 0, 3)))
      ]
    }
  }
}

# Management Groups: Top-level management group for the organisation. 
resource "azurerm_management_group" "root" {
  name         = lower("${var.global.naming.org_code}-${var.management_group_root}-mg") # Force lower-case for resource name. 
  display_name = title(var.management_group_root)                                       # Enforce title-case on root MG display name. 
}

# Management Groups: Level 1
resource "azurerm_management_group" "level1" {
  for_each                   = local.management_groups_subs_level1
  name                       = lower("${var.global.naming.org_code}-${each.key}-mg") # Force lower-case for resource name. 
  display_name               = title(each.value.display_name)                        # Use map key for MG dislpay name. 
  parent_management_group_id = azurerm_management_group.root.id                      # Nested under root management group. 
  subscription_ids           = each.value.subscriptions                              # Assign mapped subscriptions. 
}

# Management Groups: Level 2
resource "azurerm_management_group" "level2" {
  for_each                   = local.management_groups_subs_level2
  name                       = lower("${var.global.naming.org_code}-${each.key}-mg")     # Force lower-case for resource name. 
  display_name               = title(each.value.display_name)                            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.level1[each.value.parent_key].id # Use string value to map to L1 MG key for nesting.  
  subscription_ids           = each.value.subscriptions                                  # Assign mapped subscriptions. 
}

# Management Groups: Level 3
resource "azurerm_management_group" "level3" {
  for_each                   = local.management_groups_subs_level3
  name                       = lower("${var.global.naming.org_code}-${each.key}-mg")     # Force lower-case for resource name. 
  display_name               = title(each.value.display_name)                            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.level2[each.value.parent_key].id # Use string value to map to L2 MG key for nesting.  
  subscription_ids           = each.value.subscriptions                                  # Assign mapped subscriptions. 
}

# Management Groups: Level 4
resource "azurerm_management_group" "level4" {
  for_each                   = local.management_groups_subs_level4
  name                       = lower("${var.global.naming.org_code}-${each.key}-mg")     # Force lower-case for resource name. 
  display_name               = title(each.value.display_name)                            # Use map key for MG display name. 
  parent_management_group_id = azurerm_management_group.level2[each.value.parent_key].id # Use string value to map to L3 MG key for nesting.  
  subscription_ids           = each.value.subscriptions                                  # Assign mapped subscriptions. 
}
