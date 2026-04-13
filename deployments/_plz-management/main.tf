#====================================================================================#
# Management: Logging and Monitoring
# Description: 
# - Deploy resources for centralised log collection and monitoring.
#====================================================================================#

# GENERAL ------------------------------------------------------------------ #

# Naming: Generate naming convention, pre-determined values and format. 
module "naming" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Group
resource "azurerm_resource_group" "mgt" {
  name     = module.naming.resource_group
  location = var.global.location.primary
  tags     = local.tags_merged
}

# Key Vault: Stores platform secrets and certificates (for future usage).
resource "azurerm_key_vault" "mgt" {
  name                       = module.naming.key_vault
  resource_group_name        = azurerm_resource_group.mgt.name
  location                   = azurerm_resource_group.mgt.location
  tags                       = local.tags_merged
  tenant_id                  = data.azuread_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true                                     # Enforce RBAC roles over access policies (legacy).
  purge_protection_enabled   = var.key_vault_soft_purge_protection      # Enable purge protection (defautl: false).
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days # Days to keep soft-deleted.
}
