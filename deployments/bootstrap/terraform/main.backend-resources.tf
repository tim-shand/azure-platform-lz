#==============================================================================================#
# Bootstrap: Azure - Backend State Resources
# Description: 
# - Creates Resource Group for IaC backends and Storage Accounts per backend category.
# - Creates Blob Containers per deployment stack.
#==============================================================================================#

# IAC BACKEND ------------------------------------------------------------------ #

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_iac" {
  source        = "../../../modules/global-resource-naming"  # Path to module.
  prefix        = var.global.naming.org_prefix               # Example: abc
  workload      = var.deployment_stacks.bootstrap.stack_code # Example: iac
  stack_or_env  = "backend"                                  # Example: platform, workload
  ensure_unique = true                                       # Enable unique values for resources that need them.
}

# Resource Group: Single RG for all remote state backends.
resource "azurerm_resource_group" "iac" {
  name     = module.naming_iac.resource_group # Use naming module to generate resoruce group name.
  location = var.global.location.primary      # Deploy to primary region.
  tags     = local.tags_merged                # Used merged tags from `global.tfvars` and stack tags.
}

# STACK BACKEND ------------------------------------------------------------------ #

# Naming Module: Backend Categories (Platform, Workload)
module "naming_backend" {
  for_each      = toset(local.backend_categories)            # Loop each category in local variable.
  source        = "../../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix               # Example: abc
  workload      = var.deployment_stacks.bootstrap.stack_code # Example: iac
  stack_or_env  = each.value                                 # Example: platform, workload
  ensure_unique = true                                       # Enable unique values for resources that need them.
}

# Storage Accounts: Backend Categories (Platform, Workload)
resource "azurerm_storage_account" "backend" {
  for_each                        = toset(local.backend_categories) # Example: platform, workload
  name                            = module.naming_backend[each.key].storage_account
  resource_group_name             = azurerm_resource_group.iac.name
  location                        = azurerm_resource_group.iac.location
  tags                            = local.tags_merged
  account_tier                    = "Standard"  # Standard, Premium
  account_replication_type        = "LRS"       # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind                    = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, StorageV2
  https_traffic_only_enabled      = true        # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false       # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false       # SECURITY: Disable Shared Key Access in favour of Entra ID authorization.
}

# Blob Containers: Deployment Stacks (Platform)
resource "azurerm_storage_container" "backend" {
  for_each              = var.deployment_stacks # iac, mgt, gov, con
  name                  = "tfstate-${each.value.stack_name}" # Blob Container name per stack.
  storage_account_id    = azurerm_storage_account.backend["platform"].id # Force into Platform Storage Account.
  container_access_type = "private" # Disable public access.
}
