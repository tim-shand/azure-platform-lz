locals {
  # Configure Storage Account naming. 
  resource_prefix       = "${var.naming.prefix}-${var.naming.service}"
  sa_name_max_length    = 24 # Used to automatically modify Storage Account names to fit naming restrictions. 
  sa_name_random_length = 6  # Set length of random string to use with Storage Account naming. 

  # Map resource groups to create, along with a single storage account name to be created inside of it. 
  resource_stack_mapping = {
    for category, stacks in var.deployment_stacks :
    category => {
      resource_group_name  = "${var.naming.prefix}-${var.naming.service}-${category}-rg"
      storage_account_name = lower("${var.naming.prefix}${var.naming.service}${category}sa${random_integer.rndint.result}")
      stacks = [
        for stack_key, stack in stacks : merge(stack, { stack_key = stack_key })
      ]
    }
  }

  # Flatten stacks across categories for easier for_each iterations. 
  stacks_flat = {
    for item in flatten([
      for category, cat_obj in local.resource_stack_mapping : [ # Iterate each top-level category (platform, workloads). 
        for stack in cat_obj.stacks :                           # Iterates each stack in that category. 
        # Merge top level data with stack data into a new map. 
        merge(stack, { category = category, key = "${category}.${stack.stack_key}" })
      ]
    ]) : item.key => item # Sets the key in the resulting map. 
  }

  # Filter for stacks with configuration where create_repo_env = true. 
  repo_env_stacks = {
    for k, v in local.stacks_flat : k => v
    if try(v.create_repo_env, false)
  }
}
