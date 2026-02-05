#==============================================================================================#
# Bootstrap: Azure - Backend State Resources
# Description: 
# - Creates Resource Group and Storage Account for backend categories. 
# - Creates Blob Storage Containers per deployment stack, isolating state files. 
#==============================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_backend" {
  for_each      = var.backend_categories # Create naming structure for each backend category. 
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = each.key # bootstrap, platform, workload
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Groups: Backend
resource "azurerm_resource_group" "backend" {
  for_each = var.backend_categories # Create Resource Group for each backend category. 
  name     = "${module.naming_backend[each.key].full_name}-rg"
  location = var.global.location.primary
  tags     = local.tags_merged
}

# Storage Accounts: Backend
resource "azurerm_storage_account" "backend" {
  for_each                        = var.backend_categories # Create Storage Account per backend category. 
  name                            = module.naming_backend[each.key].storage_account_name
  resource_group_name             = azurerm_resource_group.backend[each.key].name
  location                        = azurerm_resource_group.backend[each.key].location
  tags                            = local.tags_merged
  account_tier                    = "Standard"  # Standard, Premium
  account_replication_type        = "LRS"       # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind                    = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, StorageV2
  https_traffic_only_enabled      = true        # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false       # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false       # SECURITY: Disable Shared Key Access in favour of Entra ID authorisation. 
  lifecycle {
    precondition {
      condition     = length(azurerm_resource_group.backend[each.key].name) <= 24
      error_message = "Storage Account names must be equal to, or less than 24 characters total."
    }
  }
}

# Blob Container: Backend Categories
resource "azurerm_storage_container" "backend" {
  for_each              = var.platform_stacks # Create Blob Container for each stack in platform_stacks map. 
  name                  = "tfstate-${each.value.stack_name}"
  storage_account_id    = azurerm_storage_account.backend[each.value.backend_category].id
  container_access_type = "private"
}

# Key Vault: Used to store shared resource IDs and names for cross-stack access. 
# resource "azurerm_key_vault" "backend" {
#   for_each                   = local.backend_categories_shared_services # Only create for categories with shared_services enabled. 
#   name                       = module.naming_backend[each.key].key_vault_name
#   resource_group_name        = azurerm_resource_group.backend[each.key].name
#   location                   = azurerm_resource_group.backend[each.key].location
#   tags                       = local.tags_merged
#   tenant_id                  = data.azuread_client_config.current.tenant_id
#   sku_name                   = "standard"
#   rbac_authorization_enabled = true  # Enforce RBAC over access policy. 
#   purge_protection_enabled   = false # Not required. 
#   soft_delete_retention_days = 7     # Set low intentionally to allow quick delete. 
# }

# App Configuration: Used to store key/value pairs for Shared Service resources (IDs/Names). 
resource "azurerm_app_configuration" "iac" {
  for_each                 = local.backend_categories_shared_services # Only create for categories with shared_services enabled. 
  name                     = "${module.naming_backend[each.key].full_name}-cfg"
  resource_group_name      = azurerm_resource_group.backend[each.key].name
  location                 = azurerm_resource_group.backend[each.key].location
  sku                      = "free"
  public_network_access    = "Enabled"
  purge_protection_enabled = false
  tags                     = local.tags_merged
}

resource "azurerm_app_configuration_key" "mg_core" {
  for_each               = local.backend_categories_shared_services
  configuration_store_id = azurerm_app_configuration.iac[each.key].id
  key                    = "gov-management-group-core"
  label                  = "Governance"
  value                  = azurerm_management_group.core.name
  depends_on = [
    azurerm_role_assignment.rbac_sp_cfg # Need the role in place before attempting to create. 
  ]
}
