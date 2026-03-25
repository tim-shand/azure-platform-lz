#====================================================================================#
# Bootstrap: Azure - RBAC Assignments
# Description: 
# - Assign RBAC roles to IaC Service Principal and current user. 
# - Provides authorization to access resources and update data. 
#====================================================================================#

# RBAC: [Service Principal] - Assign Custom role for Service Principal.  
resource "azurerm_role_assignment" "rbac_sp_custom" {
  scope              = data.azurerm_management_group.tenant_root.id # Assign at core management group. 
  role_definition_id = azurerm_role_definition.custom_role_iac_deploy.role_definition_resource_id
  principal_id       = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
  principal_type     = "ServicePrincipal"                         # Avoids Azure RBAC graph lookup delays that sometimes break CI/CD pipelines.
}

# RBAC: [Service Principal] - Assign default/built-in RBAC roles (see `var.rbac_roles_builtin`). 
resource "azurerm_role_assignment" "rbac_sp_builtin" {
  for_each             = { for a in local.rbac_assignments_builtin : "${a.rg_key}-${a.role}" => a }
  name                 = uuidv5("52c6b8b5-0000-0000-0000-000000000000", "${each.value.rg_key}-${each.value.role}") # Use a deterministic GUID to avoid duplicates.
  scope                = each.value.rg_id                                                                          # Each backend category Resource Group.
  role_definition_name = each.value.role                                                                           # Each mapped RBAC role. 
  principal_id         = azuread_service_principal.iac_sp.object_id                                                # Service Principal object ID.
  principal_type       = "ServicePrincipal"                                                                        # Avoids Azure RBAC graph lookup delays that sometimes break CI/CD pipelines.
}

# RBAC: [Current User] - Assign RBAC roles for current user. Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_cu_backend_rg" {
  for_each             = var.backend_categories
  scope                = azurerm_resource_group.backend[each.key].id  # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"              # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id # Current user object ID. 
}
