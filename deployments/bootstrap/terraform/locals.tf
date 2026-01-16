locals {
  # Scan all stacks --> discover categories --> regroup stacks under each category. 
  # - key   = Category name ("bootstrap", "platform", "workloads"). 
  # - value = Map of stacks that belong to that category. 
  stacks_by_category = {
    for c in distinct([                           # Iterate once for each unique category value found in deployment_stacks. 
      for s in var.deployment_stacks : s.category # Loop over all stacks, extract only "category" field from each stack. 
      ]) : c => {                                 # Use the category name as the key in a new map
      for k, s in var.deployment_stacks :         # Loop over all stacks again (key = stack key, s = stack object). 
      k => s if s.category == c                   # Add current stack to the map ONLY IF its category matches the outer loop category (c). 
    }
  }

  # Create map of stacks that require repository environments created. 
  repo_env_stacks = {
    for key, stack in var.deployment_stacks :
    key => stack
    if stack.create_repo_env # Only if 'create_repo_env' = true
  }

  # Tags: Merge global with deployment. 
  tags_merged = var.tags != null ? merge(var.tags, var.global.tags) : var.global.tags
}
