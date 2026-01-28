#====================================================================================#
# Bootstrap: Azure - Backend State Resources
# Description: 
# - Creates Resource Group and Storage Account for Platform and Workload categories. 
# - Creates Blob Storage Containers per deployment stack, isolating state files. 
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_backend" {
  for_each      = local.backend_categories
  source        = "../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = each.key
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Groups: Backend Categories
resource "azurerm_resource_group" "backend" {
  for_each = local.backend_categories
  name     = "${module.naming_backend[each.key].full_name}-rg"
  location = var.global.location.primary
  tags     = local.tags_merged
}

# Storage Accounts: Backend Categories
resource "azurerm_storage_account" "backend" {
  for_each                        = local.backend_categories
  name                            = module.naming_backend[each.key].storage_account_name
  resource_group_name             = azurerm_resource_group.backend[each.key].name
  location                        = azurerm_resource_group.backend[each.key].location
  tags                            = azurerm_resource_group.backend[each.key].tags
  account_tier                    = "Standard"  # Standard, Premium
  account_replication_type        = "LRS"       # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind                    = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, StorageV2
  https_traffic_only_enabled      = true        # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false       # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false       # SECURITY: Disable Shared Key Access in favour of Entra ID authorisation. 
}

resource "azurerm_storage_container" "backend" {
  for_each              = var.platform_stacks
  name                  = "tfstate-${each.value.stack_name}"
  storage_account_id    = azurerm_storage_account.backend[each.value.stack_category].id
  container_access_type = "private"
}
