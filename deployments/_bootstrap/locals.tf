locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Define backend categories is a list, used for Resource Groups and Storage Accounts.
  backend_categories = ["platform", "workload"]
}

locals {
  # Deployment Stacks: Map of objects representing the platform workloads to provision. 
  deployment_stacks = {
    "bootstrap" = {
      stack_name      = "iac-bootstrap"     # Name of stack directory and GitHub environment.
      stack_code      = "iac"               # Short code for the stack name.
      subscription_id = var.subscription_id # Subscription ID dedicated to stack (current).
    },
    "management" = {
      stack_name      = "plz-management"
      stack_code      = "mgt"
      subscription_id = var.platform_subscriptions.mgt
    },
    "governance" = {
      stack_name      = "plz-governance"
      stack_code      = "gov"
      subscription_id = var.platform_subscriptions.gov
    },
    "connectivity" = {
      stack_name      = "plz-connectivity"
      stack_code      = "con"
      subscription_id = var.platform_subscriptions.con
    }
  }
}
