locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 

  # Define backend categories used for Resource Groups and Storage Accounts.
  backend_categories = {
    platform = "platform" # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
    workload = "workload" # WARNING: Changing this value will force re-creation of resources. Used by RG and SA.
  }

  # Merge both bootstrap and platform stacks into 'deployment stacks'.
  deployment_stacks = merge(
    var.bootstrap_stacks,
    var.platform_stacks
  )
}

locals {
  rbac_roles_builtin = [
    "Key Vault Administrator",
    "Key Vault Secrets Officer",
    "Storage Blob Data Contributor",
  ]
  # Mapping Backend_Category to RBAC_Builtin_Role matrix. 
  rbac_assignments_builtin = [
    for combo in setproduct(keys(azurerm_resource_group.backend), local.rbac_roles_builtin) : { # setproduct(A, B) --> all pairs of elements from A and B.
      rg_key = combo[0]                                                                         # Each element combo is a tuple [rg_key, role].
      role   = combo[1]
      rg_id  = azurerm_resource_group.backend[combo[0]].id # Add rg_id for the Terraform resource reference.
    }
  ]
}


locals {
  # Map deployment stacks to relevant subscriptions, by data call using 'key' as identifier.
  deployment_stack_subscriptions = {
    for stack_key, stack in local.deployment_stacks :
    stack_key => {
      stack_name = stack.stack_name # Full stack name.
      stack_code = stack.stack_code # Short code for stack.
      subscription_id = one([
        for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if startswith(sub.subscription_id, stack.subscription_identifier)
      ])
      subscription_name = one([
        for sub in data.azurerm_subscriptions.all.subscriptions : sub.display_name
        if startswith(sub.subscription_id, stack.subscription_identifier)
      ])
    }
  }
}
