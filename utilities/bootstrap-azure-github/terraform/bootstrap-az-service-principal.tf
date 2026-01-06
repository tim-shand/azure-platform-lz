#=================================================================#
# Bootstrap: Azure - Service Principal, OIDC Credentials, RBAC
#=================================================================#

# Service Principal ----------------------------------------------------|
# Create App Registration and Service Principal for IaC.
resource "azuread_application" "entra_iac_app" {
  display_name = "${var.naming.prefix}-${var.naming.service}-${var.naming.project}-deploy-sp" # Service Principal name. 
  logo_image   = filebase64("./logo.png")                                                     # Image file for logo.
  owners       = [data.azuread_client_config.current.object_id]                               # Set current user as owner.
  notes        = "Bootstrap: Service Principal for IaC."                                      # Descriptive notes on purpose of the SP.
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

# RBAC Role Assignments ----------------------------------------------------|
# Assign RBAC roles for SP at top-level tenant root group. 
# NOTE: Required to deploy Management Group structure in Governance stack, and read/write to Key Vaults. 
resource "azurerm_role_assignment" "rbac_sp_contrib" {
  scope                = data.azurerm_management_group.mg_tenant_root.id  # Tenant Root MG ID.
  role_definition_name = "Contributor"                                    # Required to deploy resources in tenant. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id # Service Principal ID.
}
resource "azurerm_role_assignment" "rbac_sp_uac" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "User Access Administrator" # Required to assign RBAC permissions to resources. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kva" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Key Vault Administrator" # Required to update Key Vaults. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kvo" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Key Vault Secrets Officer" # Required to read generated Key Vault Secrets. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_stc" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Storage Blob Data Contributor" # Required to update blob storage properties. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}

# OIDC Federated Credentials ----------------------------------------------------|
# Federated credential for Service Principal.
resource "azuread_application_federated_identity_credential" "repo_main" {
  application_id = azuread_application.entra_iac_app.id
  display_name   = "oidc_${var.repo_config.owner}_${var.repo_config.repo}_MAIN"
  description    = "[REPO_MAIN]: OIDC federated credentials (${var.repo_config.branch}). Allows pipeline from main branch."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repo_config.owner}/${var.repo_config.repo}:ref:refs/heads/${var.repo_config.branch}"
}

resource "azuread_application_federated_identity_credential" "repo_pr" {
  application_id = azuread_application.entra_iac_app.id
  display_name   = "oidc_${var.repo_config.owner}_${var.repo_config.repo}_PR"
  description    = "[REPO_PR]: OIDC federated credentials (Pull Request). Allows pipeline to execute on pull request."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repo_config.owner}/${var.repo_config.repo}:pull_request"
}

# OIDC for each deployment stack/environment. Required for each repo environment. 
resource "azuread_application_federated_identity_credential" "repo_env" {
  for_each       = local.repo_env_stacks # Using map of stacks that require repo environment.
  application_id = azuread_application.entra_iac_app.id
  display_name   = "oidc_${var.repo_config.owner}_${var.repo_config.repo}_ENV_${each.value.stack_name}"
  description    = "[REPO_ENV]: OIDC federated credentials (${each.value.stack_name}). Allows pipeline to execute from repo environment."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repo_config.owner}/${var.repo_config.repo}:environment:${each.value.stack_name}"
}
