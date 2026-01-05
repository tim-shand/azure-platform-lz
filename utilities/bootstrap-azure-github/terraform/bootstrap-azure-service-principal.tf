#=================================================================#
# Bootstrap: Azure - Service Principal, OIDC Credentials, RBAC
#=================================================================#

# Create App Registration and Service Principal for IaC.
resource "azuread_application" "entra_iac_app" {
  display_name = "${var.naming.prefix}-${var.naming.service}-${var.naming.project}-sp" # Service Principal name. 
  logo_image   = filebase64("./logo.png")                                              # Image file for logo.
  owners       = [data.azuread_client_config.current.object_id]                        # Set current user as owner.
  notes        = "Bootstrap: Service Principal for IaC."                               # Descriptive notes on purpose of the SP.
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

# Federated credential for Service Principal (to be used with GitHub OIDC).
resource "azuread_application_federated_identity_credential" "github_repo_main" {
  application_id = azuread_application.entra_iac_app.id
  display_name   = "oidc-github_${var.github_config.owner}_${var.github_config.repo}_${var.github_config.branch}"
  description    = "[Bootstrap]: GitHub OIDC federated credentials (${var.github_config.branch})."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_config.owner}/${var.github_config.repo}:ref:refs/heads/${var.github_config.branch}"
}

resource "azuread_application_federated_identity_credential" "github_repo_pullrequest" {
  application_id = azuread_application.entra_iac_app.id
  display_name   = "oidc-github_${var.github_config.owner}_${var.github_config.repo}_pull-request"
  description    = "[Bootstrap]: GitHub OIDC federated credentials (Pull Request). Allows GitHub Actions to deploy on pull request."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_config.owner}/${var.github_config.repo}:pull_request"
}

# Assign RBAC roles for SP at top-level tenant root group. 
# NOTE: Required to deploy Management Group structure in Governance stack, and read/write to Key Vaults. 
resource "azurerm_role_assignment" "rbac_sp_contrib" {
  scope                = data.azurerm_management_group.mg_tenant_root.id # Tenant Root MG ID.
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.entra_iac_sp.object_id # Service Principal ID.
}
resource "azurerm_role_assignment" "rbac_sp_uac" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kva" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kvo" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
