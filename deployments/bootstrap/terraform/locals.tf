locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 

  subscriptions_by_name = {
    for sub in data.azurerm_subscriptions.all.subscriptions : # Loop each sub in data call. 
    lower(sub.display_name) => sub.subscription_id            # Key:"plz-connectivity-prod", Value:"00000000-0000-0000-0000-000000000000". 
  }

  # Map deployment stacks to relevant subscriptions, by data call using 'key' as identifier. 
  platform_stack_subscriptions = {
    for key, stack in var.platform_stacks :
    key => {
      stack_name         = stack.stack_name
      backend_category   = stack.backend_category
      subscription_id    = one(data.azurerm_subscriptions.platform[key].subscriptions).subscription_id # Select the subscription ID related to the current stack. 
      create_environment = stack.create_environment
    }
  }

  # Get stacks that require GitHub environments (exclude bootstrap). 
  platform_stacks_with_env = {
    for key, stack in local.platform_stack_subscriptions :
    key => stack
    if stack.create_environment # Filter on stacks with 'create_environment' enabled. 
  }

  # OUTPUT: Stack deployment and environment configurations. 
  deployment_configs = {
    for key, stack in local.platform_stack_subscriptions :
    key => {
      stack_name              = stack.stack_name
      subscription_id         = try(stack.subscription_id, "N/A")
      backend_category        = stack.backend_category
      backend_resource_group  = azurerm_storage_account.backend[stack.backend_category].resource_group_name
      backend_storage_account = azurerm_storage_account.backend[stack.backend_category].name
      backend_blob_container  = azurerm_storage_container.backend[key].name
      github_environment      = try(github_repository_environment.env[key].environment, "N/A")
    }
  }

  # Mapping Backend_Category to RBAC_Builtin_Role matrix. 
  rbac_assignments_builtin = [
    for combo in setproduct(keys(azurerm_resource_group.backend), var.rbac_roles_builtin) : { # setproduct(A, B) --> all pairs of elements from A and B.
      rg_key = combo[0]                                                                       # Each element combo is a tuple [rg_key, role].
      role   = combo[1]
      rg_id  = azurerm_resource_group.backend[combo[0]].id # Add rg_id for the Terraform resource reference.
    }
  ]

}
