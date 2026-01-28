locals {
  tags_merged        = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
  backend_categories = toset(var.backend_categories)          # Used to group backend resources by deployment category. 

  # Map deployment stacks to relevant subscriptions from data call using 'key' as identifier. 
  stack_subscriptions = {
    for stack_key, cfg in var.platform_stacks :
    stack_key => {
      stack_name      = cfg.stack_name
      stack_category  = cfg.stack_category
      subscription_id = one(data.azurerm_subscriptions.platform[stack_key].subscriptions).subscription_id
    }
  }
}
