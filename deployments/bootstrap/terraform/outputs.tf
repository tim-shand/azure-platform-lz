output "service_principal" {
  description = "Map detailing properties of the pipeline Service Principal."
  value = {
    object_id    = azuread_application.iac_sp.object_id       # Object ID.
    client_id    = azuread_application.iac_sp.client_id       # App ID (aka Client ID). 
    sp_id        = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
    display_name = azuread_application.iac_sp.display_name    # App Registration display name. 
  }
}
