#=====================================================#
# Platform LZ: Identity - Managed Identity
#=====================================================#

# Naming: Generate uniform, consistent name outputs to be used with resources. 
module "naming_managed_identity" {
  source   = "../../modules/global-naming"
  sections = [var.global.naming.org_code, var.global.naming.project_name, var.naming.stack_code]
}

# Resource Group.  
resource "azurerm_resource_group" "idn_rg" {
  name     = "rg-${module.naming_identity.full_name}"
  location = var.global.locations.default
  tags     = local.tags_merged
}

# Managed Identity: Create 
resource "azurerm_user_assigned_identity" "policy_deployer" {
  name                = "uai-${module.naming_managed_identity.full_name}-policydeploy"
  resource_group_name = azurerm_resource_group.idn_rg.name
  location            = azurerm_resource_group.idn_rg.location
  tags                = local.tags_merged
}

# Managed Identity: Assign Role 
resource "azurerm_role_assignment" "policy_deployer_contributor" {
  scope                = data.azurerm_management_group.platform.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.policy_deployer.principal_id
}

# Global Outputs: Stored in Key Vault
resource "azurerm_key_vault_secret" "gov_uai_policy_deployer_pid" {
  name         = "gov_uai_policy_deployer_pid"
  value        = azurerm_user_assigned_identity.policy_deployer.principal_id
  key_vault_id = data.azurerm_key_vault.globals_kv
}
