#==============================================================================================#
# Bootstrap: Azure - Backend State Resources
# Description: 
# - Creates Resource Group and Storage Accounts.
# - Creates Blob Containers per deployment stack, isolating state files.
#==============================================================================================#

# IAC ------------------------------------------------------------------ #

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_iac" {
  source        = "../../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.stack.naming.workload_code
  stack_or_env  = var.stack.naming.workload_name
  ensure_unique = true
}

resource "azurerm_resource_group" "iac" {
  name     = module.naming_iac.resource_group
  location = var.global.location.primary
  tags     = local.tags_merged
}

# BACKENDS ------------------------------------------------------------------ #

module "naming_backend" {
  for_each      = toset(local.backend_categories) # List: Platform, Workload
  source        = "../../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.stack.naming.workload_code
  stack_or_env  = each.value # platform, workload
  ensure_unique = true
}

# Storage Accounts: Backend Category
resource "azurerm_storage_account" "backend" {
  for_each                        = toset(local.backend_categories)
  name                            = module.naming_backend[each.key].storage_account
  resource_group_name             = azurerm_resource_group.iac.name     #azurerm_resource_group.backend[each.key].name
  location                        = azurerm_resource_group.iac.location #azurerm_resource_group.backend[each.key].location
  tags                            = local.tags_merged
  account_tier                    = "Standard"  # Standard, Premium
  account_replication_type        = "LRS"       # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind                    = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, StorageV2
  https_traffic_only_enabled      = true        # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false       # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false       # SECURITY: Disable Shared Key Access in favour of Entra ID authorization.
}

# Blob Container: Deployment Stacks 
resource "azurerm_storage_container" "backend" {
  for_each              = local.deployment_stacks
  name                  = "tfstate-${each.value.stack_name}"
  storage_account_id    = azurerm_storage_account.backend[each.value.backend_category].id
  container_access_type = "private"
}
