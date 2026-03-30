#====================================================================================#
# Bootstrap: Azure - Service Principal, OIDC Credentials
# Description: 
# - Creates Service Principal in Azure/Entra ID. 
# - Generates OIDC federated credentials for GitHub repository. 
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_sp" {
  source        = "../../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.stack.naming.workload_code
  stack_or_env  = "deploy"
  ensure_unique = true
}

# Service Principal: Create App Registration and Service Principal for IaC.
resource "azuread_application" "iac_sp" {
  display_name = module.naming_sp.service_principal             # Service Principal name. 
  logo_image   = filebase64("./logo.png")                       # Image file for logo.
  owners       = [data.azuread_client_config.current.object_id] # Set current user as owner.
  notes        = "Service Principal for IaC deployments."       # Descriptive notes on purpose of the SP.
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API. Will require a GA to provide consent.
    resource_access {
      id   = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9" # Application.ReadWrite.All
      type = "Role"                                 # Required to allow SP to modify itself and other apps. 
    }
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All
      type = "Role"                                 # Required to allow SP to read other applications and groups. 
    }
    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
      type = "Role"                                 # Required to allow SP to create groups in Entra ID. 
    }
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"                                 # Required to allow SP to read users in Entra ID. 
    }
  }
}

# Service Principal: Assigned to App Registration.
resource "azuread_service_principal" "iac_sp" {
  client_id   = azuread_application.iac_sp.client_id           # Map to App Registration above. 
  owners      = [data.azuread_client_config.current.object_id] # Assign current user as owner. 
  description = "Service Principal for IaC deployments."       # Descriptive notes on purpose of the SP.
}

#----------------------------------------------------------------#

# OIDC: Federated credentials for Service Principal to GitHub repository. 
resource "azuread_application_federated_identity_credential" "repo_main" {
  application_id = azuread_application.iac_sp.id
  display_name   = "oidc_MAIN_${replace(data.github_repository.repo.full_name, "/", "_")}"
  description    = "[REPO_MAIN]: OIDC federated credentials (${var.global.repo_config.branch}). Allows pipeline from main branch."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${data.github_repository.repo.full_name}:ref:refs/heads/${var.global.repo_config.branch}"
}

resource "azuread_application_federated_identity_credential" "repo_pr" {
  application_id = azuread_application.iac_sp.id
  display_name   = "oidc_PR_${replace(data.github_repository.repo.full_name, "/", "_")}"
  description    = "[REPO_PR]: OIDC federated credentials (Pull Request). Allows pipeline to execute on pull request."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${data.github_repository.repo.full_name}:pull_request"
}

#----------------------------------------------------------------#

# RBAC: [Service Principal] - Assign built-in RBAC roles (see `local.rbac_roles_builtin`). 
resource "azurerm_role_assignment" "rbac_sp_builtin" {
  for_each = { for a in local.rbac_assignments_builtin : "${a.rg_key}-${a.role}" => a }
  name = uuidv5(
    "52c6b8b5-0000-0000-0000-000000000000", "${each.value.rg_key}-${each.value.role}"
  )                                                                 # Use a deterministic GUID to avoid duplicates.
  scope                = each.value.rg_id                           # Each backend category Resource Group.
  role_definition_name = each.value.role                            # Each mapped RBAC role. 
  principal_id         = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
  principal_type       = "ServicePrincipal"                         # Avoids Azure RBAC graph lookup delays that sometimes break CI/CD pipelines.
}

#----------------------------------------------------------------#

# RBAC: [Current User] - Assign RBAC roles for current user. Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_cu_backend_rg" {
  for_each             = local.backend_categories
  scope                = azurerm_resource_group.backend[each.key].id  # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"              # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id # Current user object ID. 
}
