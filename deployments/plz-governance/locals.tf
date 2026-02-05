# GOVERNANCE: General
# ------------------------------------------------------------- #

locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# GOVERNANCE: Management Groups
# ------------------------------------------------------------- #
locals {
  # Build a subscription lookup map (sub display name to ID).
  subscriptions_by_name = {
    for sub in data.azurerm_subscriptions.all.subscriptions : # Loop each sub in data call. 
    lower(sub.display_name) => sub.subscription_id            # Key:"plz-connectivity-prod", Value:"00000000-0000-0000-0000-000000000000". 
  }

  # Lookup maps of management group IDs for parent/child assignments. 
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
}

# GOVERNANCE: Policy Initiatives (Built-In)
# ------------------------------------------------------------- #
locals {
  policy_initiatives_builtin_enabled = {
    for i, cfg in var.policy_initiatives_builtin :
    i => cfg
    if cfg.enabled == true # Only add to map if enabled. 
  }
}

# GOVERNANCE: Policy Definitions
# ------------------------------------------------------------- #
locals {
  policy_files_path = "${path.module}/policy_definitions"             # Decode all JSON policy files and add metadata. 
  policy_files      = fileset("${local.policy_files_path}", "*.json") # Discover all policy JSON files.
  policies = {
    for file_name in local.policy_files :         # Loop each file in the list of files. 
    trimsuffix(file_name, ".json") => jsondecode( # Create map using trimmed file name as key, parsed JSON as value. 
    file("${local.policy_files_path}/${file_name}")).properties
  }
  # Generate map of Policy Definition name (key), ID, name (value). Used with Initiatives. 
  policy_definition_map = {
    for k, p in azurerm_policy_definition.custom :
    k => { id = p.id, name = p.name }
  }
}
