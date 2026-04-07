# GENERAL ------------------------------------------------------------------ #

data "azuread_client_config" "current" {} # Get current user session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.
data "azurerm_subscriptions" "all" {}     # Collect all available subscriptions.

# REMOTE STATE ------------------------------------------------------------- #

data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate01"
    container_name       = "tfstate"
    key                  = ""
  }
}

# STACK -------------------------------------------------------------------- #
