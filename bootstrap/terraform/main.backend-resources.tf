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
  workload      = var.stack.naming.workload_code
  stack_or_env  = each.key # bootstrap, platform, workload
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
