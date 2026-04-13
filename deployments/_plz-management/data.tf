# GENERAL ------------------------------------------------------------------ #

data "azuread_client_config" "current" {} # Get current user session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.
data "azurerm_subscriptions" "all" {}     # Collect all available subscriptions.

# REMOTE STATE ------------------------------------------------------------- #

data "terraform_remote_state" "iac" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.remote_state_iac.resource_group_name
    storage_account_name = var.remote_state_iac.storage_account_name
    container_name       = var.remote_state_iac.container_name
    key                  = var.remote_state_iac.key
    use_azuread_auth     = true # Force Entra ID for authorisation over Shared Access Keys.
  }
}

# STACK -------------------------------------------------------------------- #
