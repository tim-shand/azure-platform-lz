# GOVERNANCE: General
# ------------------------------------------------------------- #

locals {
  # Merge global tags with stack tags. 
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Log Analytics workspace ID from MGT stack.
  law_workspace_id = data.terraform_remote_state.mgt.outputs.log_analytics_workspace.id

  # Required to modify diagnostic settings on resources.
  policy_managed_identity_roles = [
    "Monitoring Contributor" 
  ]
}

# MANAGEMENT GROUPS ------------------------------------------------------------- #

locals {
  # Lookup maps of management group IDs for created parent/child assignments, and policy assignment. 
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
        for name, sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(sub.display_name, lower(id)) # If sub name string contains MG object subscription_identifier field value.
      ]
    ]))
  }
  management_group_subscriptions_level2 = {
    for mg_name, mg in var.management_groups_level2 :
    mg_name => distinct(flatten([
      for id in mg.subscription_identifiers : [
        for name, sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(sub.display_name, lower(id)) # If sub name string contains MG object subscription_identifier field value.
      ]
    ]))
  }
  management_group_subscriptions_level3 = {
    for mg_name, mg in var.management_groups_level3 :
    mg_name => distinct(flatten([
      for id in mg.subscription_identifiers : [
        for name, sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(sub.display_name, lower(id)) # If sub name string contains MG object subscription_identifier field value.
      ]
    ]))
  }

  # Merge the individual lookup maps into a single map (flatten).
  management_groups_all = merge(
    { "core" = data.azurerm_management_group.core },
    var.management_groups_level1,
    var.management_groups_level2,
    var.management_groups_level3
  )

  # Management Group IDs for assigning Policy to MG.
  management_group_ids_all = merge(
    { "core" = data.azurerm_management_group.core.id },
    { for k, v in azurerm_management_group.level1 : k => v.id },
    { for k, v in azurerm_management_group.level2 : k => v.id },
    { for k, v in azurerm_management_group.level3 : k => v.id },
  )
}

# POLICY ASSIGNMENTS ------------------------------------------------------------- #

locals {
  # Define the policy initiative assignments with parameters per assignment.
  policy_assignments = {
    
    "initiative_core_baseline" = { # Map to policy initiative name.
      management_groups       = ["core"]
      parameters = {
        effect                = "Audit" # "Audit","Deny","Disabled"
        allowedLocations  = var.policy_param_allowed_locations
        requiredTags      = var.policy_param_required_tags
      }
    }

    "initiative_cost_controls" = { # Map to policy initiative name.
      management_groups       = ["workload","sandbox"]
      parameters = {
        effect                = "Audit" # "Audit","Deny","Disabled"
        allowedVmSkus         = var.policy_param_allowed_vm_skus
      }
    }

    "initiative_decommissioned" = { # Map to policy initiative name.
      management_groups       = ["decom"]
      parameters = {
        effect                = "Audit" # "Audit","Deny","Disabled"
      }
    }

    "initiative_diagnostics" = { # Map to policy initiative name.
      management_groups       = ["platform"]
      parameters = {
        effect                = "AuditIfNotExists" # "DeployIfNotExists","AuditIfNotExists","Disabled"
        logAnalytics          = local.law_workspace_id
      }
    }

  }
}

locals {
  # Flatten initiatives to MGs into one entry per unique assignment. 
  policy_assignments_flat = {
    for pair in flatten([
      for initiative_key, assignment in local.policy_assignments : [
        for mg_key in assignment.management_groups : {
          key            = "${initiative_key}_${mg_key}"
          initiative_key = initiative_key
          mg_key         = mg_key
          parameters     = assignment.parameters
        }
      ]
    ]) : pair.key => pair
  }
}
