locals {
  # Merge global tags with stack tags.
  tags_merged = merge(
    var.global.tags, 
    {
      CostCenter = "Platform"                                 # Useful for grouping resources for billing/financial accountability.
      Deployment = var.deployment_stacks.bootstrap.stack_name # Workload/project name, used to group and identify related resources.
    }
  )

  # Define backend categories is a list, used for Storage Accounts.
  backend_categories = ["platform", "workload"]

  # RBAC roles to assign to the Service Principal at the data plane level.
  rbac_roles_builtin = [
    "Contributor",
    "User Access Administrator",
    "Key Vault Administrator",
    "Key Vault Secrets Officer",
    "Storage Blob Data Contributor"
  ]
}

locals {
  # Resolve stack subscriptions from identifier strings.
  deployment_stacks_subscriptions = {
    for k,v in var.deployment_stacks :
    k => {
        subscription_id = one([ # Match subscription ID from data call with name part value in TFVARS.
        for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
        if strcontains(lower(sub.display_name), lower(v.subscription_identifier))
      ])
    }
  }
}

locals {
  # Select deployment stacks with environments enabled.
  deployment_stacks_github_env = {
    for k,v in var.deployment_stacks : 
    k => v
    if v.enable_github_env == true # Only create environments if enabled in TFVARS.
  }
}