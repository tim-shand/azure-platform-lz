# GOVERNANCE: General
# ------------------------------------------------------------- #
locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# GOVERNANCE: Management Groups and Subscription Assignments
# ------------------------------------------------------------- #

locals {
  # Build a subscription lookup map (sub display name to ID).
  subscriptions_by_name = {
    for sub in data.azurerm_subscriptions.all.subscriptions : # Loop each sub in data call. 
    lower(sub.display_name) => sub.subscription_id            # Key:"plz-connectivity-prod", Value:"00000000-0000-0000-0000-000000000000". 
  }

  # Lookup maps of management group IDs for created parent/child assignments, and policy assignment. 
  management_group_ids_level1 = {
    for k, v in azurerm_management_group.core :
    k => v.id
  }
  management_group_ids_level2 = {
    for k, v in azurerm_management_group.level1 : # Use level 1 MGs as base. 
    k => v.id
  }
  management_group_ids_level3 = {
    for k, v in azurerm_management_group.level2 : # Use level 2 MGs as base. 
    k => v.id
  }

  # Resolve subscriptions per management group (contains match). 
  management_group_subscriptions_level1 = {
    for mg_name, mg in var.management_groups_level1 : # Loop each MG name and details
    mg_name => distinct(flatten([                     # New map, Key: MG Name, Value: Flatten a list of subscriptions where sub name contains identifier. 
      for id in mg.subscription_identifiers : [
        for name, sub_id in local.subscriptions_by_name :
        sub_id if strcontains(name, lower(id)) # If sub name string contains MG object subscription_identifier field value. 
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
  # Merge the individual lookup maps into a single map (flatten).
  management_groups_all = merge(
    var.management_group_core,
    var.management_groups_level1,
    var.management_groups_level2,
    var.management_groups_level3
  )
  management_groups_all_created = merge(
    azurerm_management_group.core,
    azurerm_management_group.level1,
    azurerm_management_group.level2,
    azurerm_management_group.level3
  )
}

# GOVERNANCE: Policy Assignments
# ------------------------------------------------------------- #

locals {
  # Filter only MGs that have initiatives defined. 
  mg_with_initiatives = {
    for mg_name, mg in local.management_groups_all :
    mg_name => mg.policy_initiatives
    if length(mg.policy_initiatives) > 0
  }

  # Initiative specific parameters for assignment. 
  initiative_assignment_parameters = {
    core_baseline = {
      allowedLocations = var.policy_param_allowed_locations
      requiredTags     = var.policy_param_required_tags
      effect           = var.policy_effect_mode
    }
    cost_controls = {
      allowedVmSkus = var.policy_param_allowed_vm_skus
      effect        = var.policy_effect_mode
    }
    decommissioned = {
      effect = var.policy_effect_mode
    }
  }

  # Build map of MG -> initiative pairs. 
  mg_initiative_pairs = tomap({
    for pair in flatten([
      for mg_name, initiatives in local.mg_with_initiatives : [
        for initiative in initiatives : {
          key        = "${mg_name}-${initiative}"
          mg_name    = mg_name
          initiative = initiative
        }
      ]
      ]) : pair.key => {
      mg_name    = pair.mg_name
      initiative = pair.initiative
    }
  })
}
