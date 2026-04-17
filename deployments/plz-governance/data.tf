# GENERAL ------------------------------------------------------------------ #

data "azuread_client_config" "current" {} # Get current user session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.
data "azurerm_subscriptions" "all" {}     # Collect all available subscriptions.

# REMOTE STATE ------------------------------------------------------------- #

data "terraform_remote_state" "mgt" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.remote_state_resource_group
    storage_account_name = var.remote_state_storage_account
    container_name       = "tfstate-${var.deployment_stacks.management.stack_name}"
    key                  = "${var.deployment_stacks.management.stack_name}.tfstate"
    use_azuread_auth     = true # Force Entra ID for authorisation over Shared Access Keys.
  }
}

# STACK -------------------------------------------------------------------- #

# Policy Initiative (Built-in)
data "azurerm_policy_set_definition" "builtin" {
  for_each     = var.policy_initiatives_builtin # Resolve name of each initiative to ID. 
  display_name = each.key
}

# data "azurerm_management_group" "lookup" {
#   for_each     = local.management_groups_all
#   display_name = each.value.display_name
#   depends_on = [
#     azurerm_management_group.core,
#     azurerm_management_group.level1,
#     azurerm_management_group.level2,
#     azurerm_management_group.level3
#   ]
# }
