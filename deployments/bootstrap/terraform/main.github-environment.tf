#====================================================================================#
# Bootstrap: GitHub - Respository Configuration and Environments
# Description: 
# - Creates repository secrets and variables. 
# - Creates an environment per deployment stack, with environment variables. 
#====================================================================================#

# REPOSITORY LEVEL -------------------------------------------------#

# GitHub: Repo [VARIABLE] - Terraform Version
resource "github_actions_variable" "tf_version" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_VERSION"
  value         = var.terraform_version
} 

# GitHub: Repo [SECRET] - Service Principal Client ID
resource "github_actions_secret" "client_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application.iac_sp.client_id # Service Principal ID.
}

# GitHub: Repo [VARIABLE] - Azure Tenant ID
resource "github_actions_variable" "tenant_id" {
  repository    = data.github_repository.repo.name
  variable_name = "ARM_TENANT_ID"
  value         = data.azuread_client_config.current.tenant_id
}

# GitHub: Repo [VARIABLE] - Azure Subscription ID (IaC Backend)
resource "github_actions_variable" "subscription_id" {
  repository    = data.github_repository.repo.name
  variable_name = "ARM_SUBSCRIPTION_ID"
  value         = var.subscription_id # IaC Subscription.
}

# GitHub: Repo [VARIABLE] - Backend: Resource Group
resource "github_actions_variable" "iac_rg" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_RESOURCE_GROUP"
  value         = azurerm_resource_group.iac.name
}

# GitHub: Repo [VARIABLE] - Backend: Storage Account
resource "github_actions_variable" "iac_sa" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_STORAGE_ACCOUNT"
  value         = azurerm_storage_account.backend["platform"].name
}

# PER STACK --------------------------------------------------- #

# GitHub: Environment - Per Stack (enabled only)
resource "github_repository_environment" "gh_env" {
  for_each = local.deployment_stacks_github_env
  environment         = each.value.stack_name
  repository          = data.github_repository.repo.name
  prevent_self_review = false # Allow self-review for pull requests.
}

# GitHub: Environment Variable - Per ENV [Subscription ID]
resource "github_actions_environment_variable" "subscription" {
  for_each = local.deployment_stacks_github_env
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.gh_env[each.key].environment
  variable_name = "ARM_SUBSCRIPTION_ID"
  value         = local.deployment_stacks_subscriptions[each.key].subscription_id
}

# GitHub: Environment Variable - Per ENV [Container Name]
resource "github_actions_environment_variable" "container" {
  for_each = local.deployment_stacks_github_env
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.gh_env[each.key].environment
  variable_name = "TF_BACKEND_CONTAINER"
  value         = "tfstate-${each.value.stack_name}"
}

# GitHub: Environment Variable - Per ENV [State File Key]
resource "github_actions_environment_variable" "key" {
  for_each = local.deployment_stacks_github_env
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.gh_env[each.key].environment
  variable_name = "TF_BACKEND_KEY"
  value         = "${each.value.stack_name}.tfstate"
}
