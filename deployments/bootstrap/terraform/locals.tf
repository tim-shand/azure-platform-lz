locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Backend Resource Group naming. 
  backend_resource_group_name_part = "backend"

  # Define backend categories is a list, used for Storage Accounts.
  backend_categories = ["platform", "workload"]
}

locals {
  # RBAC roles to assign to the Service Principal at the data plane level.
  rbac_roles_builtin = [
    "Key Vault Administrator",
    "Key Vault Secrets Officer",
    "Storage Blob Data Contributor",
  ]
}

locals {
  # Deployment Stacks: Map of objects representing the platform workloads to provision. 
  deployment_stacks = {
    "bootstrap" = {
      stack_name       = "iac-bootstrap"     # Name of stack directory and GitHub environment.
      stack_code       = "iac"               # Short code for the stack name.
      subscription_id  = var.subscription_id # Subscription ID dedicated to stack (current).
      backend_category = "platform"
    },
    "management" = {
      stack_name       = "plz-management"
      stack_code       = "mgt"
      backend_category = "platform"
      subscription_id = one([ # Match subscription ID from data call with name part value in TFVARS.
        for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(lower(sub.display_name), lower(var.platform_subscription_identifiers.mgt))
      ])
    },
    "governance" = {
      stack_name       = "plz-governance"
      stack_code       = "gov"
      backend_category = "platform"
      subscription_id = one([
        for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(lower(sub.display_name), lower(var.platform_subscription_identifiers.gov))
      ])
    },
    "connectivity" = {
      stack_name       = "plz-connectivity"
      stack_code       = "con"
      backend_category = "platform"
      subscription_id = one([
        for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(lower(sub.display_name), lower(var.platform_subscription_identifiers.con))
      ])
    }
  }
}
