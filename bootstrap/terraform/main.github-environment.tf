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
  value         = azurerm_resource_group.backend[var.backend_categories["platform"].name].name
}

# GitHub: Repo [VARIABLE] - Backend: Storage Account
resource "github_actions_variable" "iac_sa" {
  repository    = data.github_repository.repo.name
  variable_name = "TF_BACKEND_SA"
  value         = azurerm_storage_account.backend[var.backend_categories["platform"].name].name
}

# GitHub: Repo [VARIABLE] - Shared: Key Vault (Name)
resource "github_actions_variable" "iac_kv" {
  for_each      = local.backend_categories_keyvault # Create GitHub repo variable for each Key Vault. 
  repository    = data.github_repository.repo.name
  variable_name = "KV_NAME_${upper(each.key)}"
  value         = azurerm_key_vault.backend[each.key].name
}

# GitHub: Repo [VARIABLE] - Shared: Key Vault (Resource Group)
resource "github_actions_variable" "iac_kv_rg" {
  for_each      = local.backend_categories_keyvault # Create GitHub repo variable for each Key Vault. 
  repository    = data.github_repository.repo.name
  variable_name = "KV_RESOURCE_GROUP_${upper(each.key)}"
  value         = azurerm_key_vault.backend[each.key].resource_group_name
}

#----------------------------------------------------------------#

# GitHub: Environment - Create environments per deployment stack. 
resource "github_repository_environment" "env" {
  for_each    = local.platform_stacks_with_env # Create separate environment per stack, only for those with 'create_env=true'. 
  repository  = data.github_repository.repo.name
  environment = each.value.stack_name # Use variable property 'stack_name' for GitHub environment naming. 
}

# GitHub: Environment [VARIABLE] - Subscription ID
resource "github_actions_environment_variable" "env_sub" {
  for_each      = local.platform_stacks_with_env
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.env[each.key].environment
  variable_name = "ARM_SUBSCRIPTION_ID"
  value         = each.value.subscription_id
}

# GitHub: Environment [VARIABLE] - Backend: Container
resource "github_actions_environment_variable" "env_cn" {
  for_each      = local.platform_stacks_with_env
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.env[each.key].environment
  variable_name = "TF_BACKEND_CONTAINER"
  value         = azurerm_storage_container.backend[each.key].name
}

# GitHub: Environment [VARIABLE] - Backend: State File Name
resource "github_actions_environment_variable" "env_key" {
  for_each      = local.platform_stacks_with_env
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.env[each.key].environment
  variable_name = "TF_BACKEND_KEY"
  value         = "azure-${each.value.stack_name}.tfstate"
}
