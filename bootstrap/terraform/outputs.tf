output "deployments" {
  description = "Map of environment configuration to deploy."
  value       = local.deployment_configs
}

output "service_principal_name" {
  description = "Name of the pipeline Service Principal."
  value       = azuread_application.iac_sp.display_name
}
