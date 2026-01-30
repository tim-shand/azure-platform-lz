# Root Management Group: Pass in tenant ID to get root management group.
data "azurerm_management_group" "tenant_root" {
  name = data.azuread_client_config.current.tenant_id # Obtained from current session. 
}

# Subscriptions: Collect all available subscriptions, to be nested under core management group.  
data "azurerm_subscriptions" "all" {}

# Subscriptions: Resolve subscription ID where display name contains string value for platform subscriptions. 
data "azurerm_subscriptions" "platform" {
  for_each              = var.platform_stacks
  display_name_contains = each.value.subscription_identifier # Provided in TFVARS file (no IDs in repo). 
}

# GitHub: Get data for existing GitHub Repository. 
data "github_repository" "repo" {
  full_name = "${var.global.repo_config.org}/${var.global.repo_config.repo}"
}
