#=================================================================#
# Bootstrap: Azure - Service Principal, OIDC Credentials
#=================================================================#

# Service Principal ----------------------------------------------------|
# Create App Registration and Service Principal for IaC.
resource "azuread_application" "entra_iac_app" {
  display_name = "sp-${module.naming_bootstrap.full_name}-deploy"       # Service Principal name. 
  logo_image   = filebase64("./logo.png")                               # Image file for logo.
  owners       = [data.azuread_client_config.current.object_id]         # Set current user as owner.
  notes        = "${var.naming.stack_name}: Service Principal for IaC." # Descriptive notes on purpose of the SP.
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API. Will require a GA to provide consent.
    resource_access {
      id   = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9" # Application.ReadWrite.All
      type = "Role"                                 # Required to allow SP to modify itself and others. 
    }
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All
      type = "Role"                                 # Required to allow SP to read other applications and groups. 
    }
    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
      type = "Role"                                 # Required to allow SP to create groups in Entra ID. 
    }
  }
}

# Service Principal for the App Registration.
resource "azuread_service_principal" "entra_iac_sp" {
  client_id                    = azuread_application.entra_iac_app.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# OIDC Federated Credentials ----------------------------------------------------|
# Federated credential for Service Principal.
resource "azuread_application_federated_identity_credential" "repo_main" {
  application_id = azuread_application.entra_iac_app.id
  #display_name   = "oidc_${var.global.repo_config.org}_${var.global.repo_config.repo}_MAIN"
  display_name = "oidc_MAIN_${replace(data.github_repository.repo.full_name, "/", "_")}"
  #data.github_repository.repo.full_name
  description = "[REPO_MAIN]: OIDC federated credentials (${var.global.repo_config.branch}). Allows pipeline from main branch."
  audiences   = ["api://AzureADTokenExchange"]
  issuer      = "https://token.actions.githubusercontent.com"
  #subject        = "repo:${var.global.repo_config.org}/${var.global.repo_config.repo}:ref:refs/heads/${var.global.repo_config.branch}"
  subject = "repo:${data.github_repository.repo.full_name}:ref:refs/heads/${var.global.repo_config.branch}"
}

resource "azuread_application_federated_identity_credential" "repo_pr" {
  application_id = azuread_application.entra_iac_app.id
  #display_name   = "oidc_${var.global.repo_config.org}_${var.global.repo_config.repo}_PR"
  display_name = "oidc_PR_${replace(data.github_repository.repo.full_name, "/", "_")}"
  description  = "[REPO_PR]: OIDC federated credentials (Pull Request). Allows pipeline to execute on pull request."
  audiences    = ["api://AzureADTokenExchange"]
  issuer       = "https://token.actions.githubusercontent.com"
  #subject        = "repo:${var.global.repo_config.org}/${var.global.repo_config.repo}:pull_request"
  subject = "repo:${data.github_repository.repo.full_name}:pull_request"
}

# OIDC for each deployment stack/environment. Required for each repo environment. 
resource "azuread_application_federated_identity_credential" "repo_env" {
  for_each       = local.repo_env_stacks # Using map of stacks that require repo environment.
  application_id = azuread_application.entra_iac_app.id
  #display_name   = "oidc_${var.global.repo_config.org}_${var.global.repo_config.repo}_ENV_${each.value.stack_name}"
  display_name = "oidc_ENV_${each.value.stack_name}_${replace(data.github_repository.repo.full_name, "/", "_")}"
  description  = "[REPO_ENV]: OIDC federated credentials (${each.value.stack_name}). Allows pipeline to execute from repo environment."
  audiences    = ["api://AzureADTokenExchange"]
  issuer       = "https://token.actions.githubusercontent.com"
  #subject        = "repo:${var.global.repo_config.org}/${var.global.repo_config.repo}:environment:${each.value.stack_name}"
  subject = "repo:${data.github_repository.repo.full_name}:environment:${each.value.stack_name}"
}
