#=================================================================#
# Bootstrap: GitHub - Environments, Secrets, and Variables
#=================================================================#

# Get data for existing GitHub Repository.
data "github_repository" "repo" {
  full_name = "${var.github_config.owner}/${var.github_config.repo}"
}

# GitHub: Global -----------------------------------------------|

# GitHub: Repo [SECRET] - Azure Tenant ID
resource "github_actions_secret" "gh_secret_tenant_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azuread_client_config.current.tenant_id
}

# GitHub: Repo [SECRET] - Azure IaC Subscription
resource "github_actions_secret" "gh_secret_subscription_id_iac" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARM_SUBSCRIPTION_ID_IAC"
  plaintext_value = var.deployment_stacks.bootstrap.bootstrap.subscription_id # Subscription ID to be used for IaC.
}

# GitHub: Repo [SECRET] - Service Principal Client ID
resource "github_actions_secret" "gh_secret_client_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application.entra_iac_app.client_id # Service Principal federated credential ID.
}

# GitHub: Environments + IaC Backend Configuration --------------------------------|

# Create GitHub environments per deployment stack. 
resource "github_repository_environment" "gh_env" {
  for_each    = local.github_env_stacks
  environment = each.value.stack_name
  repository  = data.github_repository.repo.name
}

# Create variables per environment. 
resource "github_actions_environment_variable" "gh_env_var_sub" {
  for_each      = local.github_env_stacks
  repository    = data.github_repository.repo.name
  environment   = each.value.stack_name # Loop for each stack environment. 
  variable_name = "ARM_SUBSCRIPTION_ID"
  value         = each.value.subscription_id
}

resource "github_actions_environment_variable" "gh_env_var_rg" {
  for_each      = local.github_env_stacks
  repository    = data.github_repository.repo.name
  environment   = each.value.stack_name # Loop for each stack environment. 
  variable_name = "TF_BACKEND_RG"
  value         = azurerm_resource_group.iac_rg[each.value.category].name
}

resource "github_actions_environment_variable" "gh_env_var_sa" {
  for_each      = local.github_env_stacks
  repository    = data.github_repository.repo.name
  environment   = each.value.stack_name # Loop for each stack environment. 
  variable_name = "TF_BACKEND_SA"
  value         = azurerm_storage_account.iac_sa[each.value.category].name
}

resource "github_actions_environment_variable" "gh_env_var_cn" {
  for_each      = local.github_env_stacks
  repository    = data.github_repository.repo.name
  environment   = each.value.stack_name # Loop for each stack environment. 
  variable_name = "TF_BACKEND_CONTAINER"
  value         = azurerm_storage_container.iac_cn[each.key].name
}

resource "github_actions_environment_variable" "gh_env_var_key" {
  for_each      = local.github_env_stacks
  repository    = data.github_repository.repo.name
  environment   = each.value.stack_name # Loop for each stack environment. 
  variable_name = "TF_BACKEND_KEY"
  value         = "azure-${each.value.stack_name}.tfstate"
}
