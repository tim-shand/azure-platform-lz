locals {
  root_key = keys(var.management_group_root)[0] # Grab the first (and only) key in the map for root MG. 
}

locals {
  # Map matching subscriptions to management groups based on first three segments of the subscription ID. 
  management_groups_subs_root = {
    for mg, details in var.management_group_root :
    mg => {
      display_name = details.display_name
      subscriptions = [
        for sub in var.subscriptions : sub.subscription_id
        if contains(details.subscription_id_filter, join("-", slice(split("-", sub.subscription_id), 0, 3)))
      ]
    }
  }
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
  management_groups_subs_level5 = {
    for mg, details in var.management_groups_level5 :
    mg => {
      display_name = details.display_name
      parent_key   = details.parent_mg_name # Map static 'parent_mg_name' value to L4 MG key. 
      subscriptions = [
        for sub in var.subscriptions : sub.subscription_id
        if contains(details.subscription_id_filter, join("-", slice(split("-", sub.subscription_id), 0, 3)))
      ]
    }
  }
}
