# GENERAL ------------------------------------------------------ #

data "azuread_client_config" "current" {} # Get current authentication session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.

# STACK ------------------------------------------------------ #

# Root Management Group: Pass in tenant ID to get root management group.
data "azurerm_management_group" "tenant_root" {
  name = data.azuread_client_config.current.tenant_id # Obtained from current session. 
}

data "azurerm_role_definition" "entra_diag" {
  name = "Contributor"
}

# Subscriptions: Collect all available subscriptions.
# Used to resolve in locals using `var.platform_subscription_identifiers`.
data "azurerm_subscriptions" "all" {}

# GitHub: Get data for provided GitHub Repository. 
data "github_repository" "repo" {
  full_name = "${var.global.repo_config.org}/${var.global.repo_config.repo}"
}
