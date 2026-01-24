#=================================================================#
# Bootstrap: Azure - Global Outputs
#=================================================================#

# Used to contain resource IDs, names, and other data required by other stacks/deployments. 

# Globals: Resource Group
resource "azurerm_resource_group" "globals" {
  name     = "rg-${module.naming_bootstrap.full_name}-globals"
  location = var.global.locations.default
  tags     = local.tags_merged
}

# Globals: Key Vault - Used to store data (tables require Shared Access Keys). 
resource "azurerm_key_vault" "globals" {
  name                       = "kv-${module.naming_bootstrap.full_name}-${module.naming_bootstrap.random_string}"
  resource_group_name        = azurerm_resource_group.globals.name
  location                   = azurerm_resource_group.globals.location
  tags                       = local.tags_merged
  tenant_id                  = data.azuread_client_config.current.tenant_id
  sku_name                   = var.kv_sku
  rbac_authorization_enabled = true
  purge_protection_enabled   = var.kv_purge_protection_enabled
  soft_delete_retention_days = var.kv_soft_delete_retention_days
}

# Global Outputs: Stored in Key Vault
resource "azurerm_key_vault_secret" "iac_sp_id" {
  name         = "ServicePrincipal-IaC-Deploy"
  value        = azuread_service_principal.entra_iac_sp.display_name
  key_vault_id = azurerm_key_vault.globals.id
  depends_on   = [azurerm_role_assignment.rbac_sp_kvs] # Requires RBAC to be in place before adding secret to KV. 
}
