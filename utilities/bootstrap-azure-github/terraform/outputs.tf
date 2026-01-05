#=================================================================#
# Azure Bootstrap: Outputs
#=================================================================#

# Service Principal -----------------------------------|

output "service_principal_name" {
  description = "Display name of the Service Principal."
  value       = azuread_application.entra_iac_app.display_name
}

# Backend Resources -----------------------------------|

output "bootstrap_iac_rg" {
  description = "The name of the Resource Group for bootstrap resources."
  value       = azurerm_resource_group.iac_rg["bootstrap"].name
}

output "bootstrap_iac_sa" {
  description = "The name of the Storage Account for bootstrap resources."
  value       = azurerm_storage_account.iac_sa["bootstrap"].name # Keyed by the deployment_stack key.
}

output "bootstrap_iac_cn" {
  description = "The name of the Storage Account Container for the bootstrap backend."
  value       = azurerm_storage_container.iac_cn["bootstrap.bootstrap"].name # Keyed by the flattened stack key.
}

output "stacks" {
  description = "List of deployments stacks to configure."
  value       = [for env in values(github_repository_environment.repo_env) : env.environment]
}

output "service_principal_oidc" {
  description = "List of OIDC federated credential display names."
  value       = [for cred in values(azuread_application_federated_identity_credential.repo_env) : cred.display_name]
}
