locals {
  # Build a lookup map (display name to ID).
  subscriptions_by_name = {
    for sub in data.azurerm_subscriptions.all.subscriptions :
    lower(sub.display_name) => sub.subscription_id # "plz-connectivity-prod":"00000000-0000-0000-0000-000000000000"
  }

  # Resolve subscriptions per management group (contains match). 
  management_group_subscriptions_level1 = {
    for mg_name, mg in var.management_groups_level1 :
    mg_name => distinct(flatten([
      for id in mg.subscription_identifiers : [
        for name, sub_id in local.subscriptions_by_name :
        sub_id if strcontains(name, lower(id))
      ]
    ]))
  }
  management_group_subscriptions_level2 = {
    for mg_name, mg in var.management_groups_level2 :
    mg_name => distinct(flatten([
      for id in mg.subscription_identifiers : [
        for name, sub_id in local.subscriptions_by_name :
        sub_id if strcontains(name, lower(id))
      ]
    ]))
  }
  management_group_subscriptions_level3 = {
    for mg_name, mg in var.management_groups_level3 :
    mg_name => distinct(flatten([
      for id in mg.subscription_identifiers : [
        for name, sub_id in local.subscriptions_by_name :
        sub_id if strcontains(name, lower(id))
      ]
    ]))
  }

  # Lookup maps of management group IDs for parent/child. 
  management_group_ids_level2 = {
    for k, v in azurerm_management_group.level1 :
    k => v.id
  }
  management_group_ids_level3 = {
    for k, v in azurerm_management_group.level2 :
    k => v.id
  }
}
