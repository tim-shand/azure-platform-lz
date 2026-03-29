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
    resource_group  = azurerm_resource_group.backend["platform"].name
    storage_account = azurerm_storage_account.backend["platform"].name
    blob_container  = azurerm_storage_container.bootstrap.name
  }
}

output "management_group_core" {
  description = "Map of details for the core (top level) management group."
  value = {
    id           = azurerm_management_group.core.id
    name         = azurerm_management_group.core.name
    display_name = azurerm_management_group.core.display_name
  }
}
