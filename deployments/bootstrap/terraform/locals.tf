locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 

  # Map subscription IDs and names.
  subscriptions_resolved = {
    for sub in data.azurerm_subscriptions.all.subscriptions : # Loop each sub in data call. 
    lower(sub.display_name) => sub.subscription_id            # Key:"plz-connectivity-prod", Value:"00000000-0000-0000-0000-000000000000". 
  }

  # Define backend categories used for Resource Groups and Storage Accounts.
  backend_categories = {
    platform = "platform" # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
    workload = "workload" # WARNING: Changing this value will force re-creation of resources. Used by RG and SA.
  }
}

locals {
  # Map deployment stacks to relevant subscriptions, by data call using 'key' as identifier.
  platform_stack_subscriptions = {
    for stack_key, stack in var.platform_stacks :
    stack_key => {
      stack_name = stack.stack_name # Full stack name.
      stack_code = stack.stack_code # Short code for stack.
      subscription_id = one([
        for sub in local.subscriptions_resolved : sub.subscription_id
        if startswith(sub.subscription_id, stack.subscription_identifier)
      ])
      subscription_name = one([
        for sub in local.subscriptions_resolved : sub.display_name
        if startswith(sub.subscription_id, stack.subscription_identifier)
      ])
    }
  }
}
