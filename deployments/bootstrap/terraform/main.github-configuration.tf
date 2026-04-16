#====================================================================================#
# Bootstrap: GitHub - Respository Configuration and Environments
# Description: 
# - Creates repository secrets and variables. 
# - Creates an environment per deployment stack, with environment specific variables. 
#====================================================================================#

# SECRETS ----------------------------------------------------- #

# GitHub: Repo [SECRET] - Service Principal Client ID
resource "github_actions_secret" "client_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application.iac_sp.client_id # Service Principal ID.
}

# VARIABLES --------------------------------------------------- #

# GitHub: Repo [VARIABLE] - Terraform Version
resource "github_actions_variable" "tf_version" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_VERSION"
  value         = var.terraform_version
}

# GitHub: Repo [VARIABLE] - Azure Tenant ID
resource "github_actions_variable" "tenant_id" {
  repository    = data.github_repository.repo.name
  variable_name = "ARM_TENANT_ID"
  value         = data.azuread_client_config.current.tenant_id
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

# GitHub: Repo [VARIABLE] - Backend: Container
resource "github_actions_variable" "stack_container" {
  for_each      = local.deployment_stacks
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_CONTAINER_${upper(each.value.stack_code)}"
  value         = azurerm_storage_container.backend[each.key].name
}

# GitHub: Repo [VARIABLE] - Backend: State File Name
resource "github_actions_variable" "stack_key" {
  for_each      = local.deployment_stacks
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_KEY_${upper(each.value.stack_code)}"
  value         = "${each.value.stack_name}.tfstate"
}

# GitHub: Repo [VARIABLE] - Stack Subscription ID
resource "github_actions_variable" "stack_sub" {
  for_each      = local.deployment_stacks
  repository    = data.github_repository.repo.name
  variable_name = "SUBSCRIPTION_ID_${upper(each.value.stack_code)}"
  value         = each.value.subscription_id
}
