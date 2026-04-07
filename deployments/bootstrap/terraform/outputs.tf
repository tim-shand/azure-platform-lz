output "service_principal" {
  description = "Map detailing properties of the pipeline Service Principal."
  value = {
    object_id    = azuread_application.iac_sp.object_id       # Object ID.
    client_id    = azuread_application.iac_sp.client_id       # App ID (aka Client ID). 
    sp_id        = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
    display_name = azuread_application.iac_sp.display_name    # App Registration display name. 
  }
}

output "bootstrap_backend" {
  description = "Map of bootstrap backend details for state file migration."
  value = {
    resource_group  = azurerm_resource_group.iac.name
    storage_account = azurerm_storage_account.backend["platform"].name
    blob_container  = azurerm_storage_container.backend["bootstrap"].name
    state_key       = "${lower(var.stack.naming.workload_code)}-${lower(var.stack.naming.workload_name)}.tfstate"
  }
}

output "management_group_core" {
  description = "Core management group object."
  value       = azurerm.management_group_core
}
