#====================================================================================#
# Bootstrap: RBAC Role Assignments
# Description: 
# - Assign RBAC roles to resources.
#====================================================================================#

# Create a deterministic GUID to avoid duplicates. Use all three components in the name to guarantee uniqueness.
resource "random_uuid" "uuid" {}

# SERVICE PRINCIPAL --------------------------------------------------- #

# RBAC: [Service Principal] - Assign Custom role for Service Principal.  
resource "azurerm_role_assignment" "rbac_sp_custom" {
  name = uuidv5( # Use multiple components in the name to guarantee uniqueness.
    random_uuid.uuid.result,
    azurerm_role_definition.custom_role_iac_deploy.role_definition_resource_id
  )
  scope              = data.azurerm_management_group.tenant_root.id # Assign at tenant root group. 
  role_definition_id = azurerm_role_definition.custom_role_iac_deploy.role_definition_resource_id
  principal_id       = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
  principal_type     = "ServicePrincipal"                         # Avoids Azure RBAC graph lookup delays that sometimes break CI/CD pipelines.
}

# RBAC: [Service Principal] - Assign built-in RBAC roles (see `local.rbac_roles_builtin`). 
resource "azurerm_role_assignment" "rbac_sp_builtin" {
  for_each = toset(local.rbac_roles_builtin)
  name = uuidv5(
    random_uuid.uuid.result,
    "${azurerm_resource_group.iac.id}/${each.value}/${azuread_service_principal.iac_sp.object_id}"
  )
  scope                = azurerm_resource_group.iac.id              # Backend Resource Group.
  role_definition_name = each.value                                 # Each RBAC role. 
  principal_id         = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
  principal_type       = "ServicePrincipal"                         # Avoids Azure RBAC graph lookup delays that sometimes break CI/CD pipelines.
}

# CURRENT USER -------------------------------------------------------- #

# RBAC: [Current User] - Assign RBAC roles for current user. Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_cu_backend_rg" {
  name = uuidv5(
    random_uuid.uuid.result,
    "${azurerm_resource_group.iac.id}/Storage Blob Data Contributor/${data.azuread_client_config.current.object_id}"
  )
  scope                = azurerm_resource_group.iac.id                # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"              # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id # Current user object ID. 
}
