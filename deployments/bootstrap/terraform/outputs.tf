output "service_principal" {
  description = "Map detailing properties of the pipeline Service Principal."
  value = {
    object_id    = azuread_application.iac_sp.object_id
    app_id       = azuread_application.iac_sp.app_id
    sp_id        = azuread_service_principal.app_id
    display_name = azuread_application.iac_sp.display_name
  }
}
