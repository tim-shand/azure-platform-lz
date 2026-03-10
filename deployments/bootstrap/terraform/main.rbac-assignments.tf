#====================================================================================#
# Bootstrap: Azure - RBAC Assignments
# Description: 
# - Assign RBAC roles to IaC Service Principal and current user. 
# - Provides authorization to access resources and update data. 
#====================================================================================#

# RBAC: [Service Principal] - Assign RBAC roles for Service Principal.  
resource "azurerm_role_assignment" "rbac_sp_custom" {
  scope                = azurerm_management_group.core.id                                           # Assign at core management group. 
  role_definition_name = azurerm_role_definition.custom_role_iac_deploy.role_definition_resource_id # Required to deploy all resource types in tenant. 
  principal_id         = azuread_service_principal.iac_sp.object_id                                 # Service Principal ID.
}

# RBAC: [Current User] - Assign RBAC roles for current user. Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_cu_backend_rg" {
  for_each             = var.backend_categories
  scope                = azurerm_resource_group.backend[each.key].id  # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"              # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id # Current user object ID. 
}
