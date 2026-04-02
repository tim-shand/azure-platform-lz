# GENERAL ------------------------------------------------------------------ #

data "azuread_client_config" "current" {} # Get current user session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.
data "azurerm_subscriptions" "all" {}     # Collect all available subscriptions.

# STACK ------------------------------------------------------------------ #
