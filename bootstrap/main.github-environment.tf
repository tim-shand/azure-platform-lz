#====================================================================================#
# Bootstrap: GitHub - Respository Configuration and Environments
# Description: 
# - Creates repository secrets and variables. 
# - Creates an environment per deployment stack, with environment specific variables. 
#====================================================================================#

# GitHub: Repo [VARIABLE] - Azure Tenant ID
resource "github_actions_variable" "tenant_id" {
  repository    = data.github_repository.repo.name
  variable_name = "ARM_TENANT_ID"
  value         = data.azuread_client_config.current.tenant_id
}

# GitHub: Repo [VARIABLE] - Azure Subscription (IaC)
resource "github_actions_variable" "sub_iac" {
  repository    = data.github_repository.repo.name
  variable_name = "ARM_SUBSCRIPTION_ID_IAC"
  value         = data.azurerm_subscription.current.subscription_id # Current in use IaC subscription. 
}

# GitHub: Repo [SECRET] - Service Principal Client ID
resource "github_actions_secret" "client_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application.iac_sp.client_id # Service Principal ID.
}

# GitHub: Repo [VARIABLE] - Backend: Resource Group
resource "github_actions_variable" "iac_rg" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_RG"
  value         = azurerm_resource_group.backend[var.backend_categories[1]].name # Selectively choose the second item in category list (should be platform). 
}

# GitHub: Repo [VARIABLE] - Backend: Storage Account
resource "github_actions_variable" "iac_sa" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_SA"
  value         = azurerm_resource_group.backend[var.backend_categories[1]].name
}

#----------------------------------------------------------------#

# GitHub: Environments - Create environments per deployment stack. 
resource "github_repository_environment" "env" {
  for_each    = var.platform_stacks # Create seaprate environment per stack. 
  repository  = data.github_repository.repo.name
  environment = each.value.stack_name # Use variable property 'stack_name' for GitHub environment naming. 
}

# GitHub: Environments [VARIABLE] - Subscription ID
resource "github_actions_environment_variable" "env_rg" {
  for_each      = local.stack_subscriptions
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.env[each.key].environment
  variable_name = "ARM_SUBSCRIPTION_ID"
  value         = each.value.subscription_id
}
