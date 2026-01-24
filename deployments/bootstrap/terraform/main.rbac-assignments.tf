#=================================================================#
# Bootstrap: Azure - RBAC Assignments
#=================================================================#

# Service Principal ----------------------------------------------------|
# Assign RBAC roles for SP at top-level tenant root group.  
resource "azurerm_role_assignment" "rbac_sp_contrib" {
  scope                = data.azurerm_management_group.mg_tenant_root.id  # Tenant Root MG ID.
  role_definition_name = "Contributor"                                    # Required to deploy resources in tenant. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id # Service Principal ID.
}
resource "azurerm_role_assignment" "rbac_sp_uac" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "User Access Administrator" # Required to assign RBAC permissions to resources. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kva" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Key Vault Administrator" # Required to update Key Vaults. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kvo" {
  scope                = data.azurerm_management_group.mg_tenant_root.id
  role_definition_name = "Key Vault Secrets Officer" # Required to read generated Key Vault Secrets. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_kvs" {
  scope                = azurerm_key_vault.globals.id # Global Outputs Key Vault. 
  role_definition_name = "Key Vault Secrets User"     # Required to read generated Key Vault Secrets. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}
resource "azurerm_role_assignment" "rbac_sp_rg" {
  for_each             = local.stacks_by_category                   # Assign to each IaC backend Resource Group. 
  scope                = azurerm_resource_group.iac_rg[each.key].id # Must be assigned on the resource plane, cannot be inherited from MG. 
  role_definition_name = "Storage Blob Data Contributor"            # Required to access and update blob storage properties. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}

# Current User ---------------------------------------------------------------|
resource "azurerm_role_assignment" "rbac_cu_rg" { # Current User: Required when 'shared_access_key_enabled=false'. 
  for_each             = local.stacks_by_category
  scope                = azurerm_resource_group.iac_rg[each.key].id # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"            # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id
}
resource "azurerm_role_assignment" "rbac_cu_kvs" {
  scope                = azurerm_key_vault.globals.id # Global Outputs Key Vault. 
  role_definition_name = "Key Vault Secrets User"     # Required to read generated Key Vault Secrets. 
  principal_id         = data.azuread_client_config.current.object_id
}
