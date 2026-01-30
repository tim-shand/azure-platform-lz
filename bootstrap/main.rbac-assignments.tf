#====================================================================================#
# Bootstrap: Azure - RBAC Assignments
# Description: 
# - Assign RBAC roles to IaC Service Principal and current user. 
# - Provides authorization to access resources and update data. 
#====================================================================================#

# RBAC: [Service Principal] - Assign RBAC roles for Service Principal.  
resource "azurerm_role_assignment" "rbac_sp_contrib" {
  scope                = azurerm_management_group.core.id           # Assign at created top-level management group. 
  role_definition_name = "Contributor"                              # Required to deploy all resource types in tenant. 
  principal_id         = azuread_service_principal.iac_sp.object_id # Service Principal ID.
}
resource "azurerm_role_assignment" "rbac_sp_uac" {
  scope                = azurerm_management_group.core.id # Assign at created top-level management group. 
  role_definition_name = "User Access Administrator"      # Required to assign RBAC permissions to resources. 
  principal_id         = azuread_service_principal.iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kva" {
  scope                = azurerm_management_group.core.id # Assign at created top-level management group. 
  role_definition_name = "Key Vault Administrator"        # Required to update Key Vaults. 
  principal_id         = azuread_service_principal.iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kvo" {
  scope                = azurerm_management_group.core.id # Assign at created top-level management group. 
  role_definition_name = "Key Vault Secrets Officer"      # Required to create Key Vault Secrets. 
  principal_id         = azuread_service_principal.iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kvu" {
  scope                = azurerm_management_group.core.id # Assign at created top-level management group. 
  role_definition_name = "Key Vault Secrets User"         # Required to read Key Vault Secrets. 
  principal_id         = azuread_service_principal.iac_sp.object_id
}


# RBAC: [Current User] - Assign RBAC roles for current user. Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_cu_backend_rg" {
  for_each             = var.backend_categories
  scope                = azurerm_resource_group.backend[each.key].id  # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"              # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id # Current user object ID. 
}
resource "azurerm_role_assignment" "rbac_sp_backend_rg" {
  for_each             = var.backend_categories                      # Assign to each IaC backend Resource Group. 
  scope                = azurerm_resource_group.backend[each.key].id # Must be assigned on the resource plane, cannot be inherited from MG. 
  role_definition_name = "Storage Blob Data Contributor"             # Required to access and update blob storage properties. 
  principal_id         = azuread_service_principal.iac_sp.object_id
}
