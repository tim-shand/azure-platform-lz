locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
  backend_category_map = {
    global    = "global"    # Map backend category name to purpose (opinionated - DO NOT change). 
    platform  = "platform"  # Map backend category name to purpose (opinionated - DO NOT change).
    workloads = "workloads" # Map backend category name to purpose (opinionated - DO NOT change).
  }

  # Map deployment stacks to relevant subscriptions from data call using 'key' as identifier. 
  platform_stack_subscriptions = {
    for key, stack in var.platform_stacks :
    key => {
      stack_name      = stack.stack_name
      stack_category  = stack.stack_category
      subscription_id = one(data.azurerm_subscriptions.platform[key].subscriptions).subscription_id # Select the subscription ID related to the current stack. 
      create_env      = stack.create_env
    }
  }

  # Get stacks that require GitHub environments (should skip bootstrap). 
  platform_stacks_with_env = {
    for key, stack in local.platform_stack_subscriptions :
    key => stack
    if stack.create_env # Filter on this. 
  }
}
