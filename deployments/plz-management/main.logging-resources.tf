#====================================================================================#
# Management: Log Analytics Workspace
# Description: 
# - Deploy LAW for centralised log collection.  
# - Deploy Storage Account for log archiving.    
#====================================================================================#

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "mgt_logs" {
  name                = "${module.naming_mgt_logs.full_name}-law"
  resource_group_name = azurerm_resource_group.mgt_logs.name
  location            = azurerm_resource_group.mgt_logs.location
  tags                = local.tags_merged
  sku                 = "PerGB2018"
  retention_in_days   = var.law_retenion_days
}

# Storage Account: Retain archived logs from Log Analytics. 
resource "azurerm_storage_account" "mgt_logs" {
  name                            = module.naming_mgt_logs.storage_account_name
  resource_group_name             = azurerm_resource_group.mgt_logs.name
  location                        = azurerm_resource_group.mgt_logs.location
  tags                            = local.tags_merged
  account_tier                    = "Standard"  # Standard, Premium
  account_replication_type        = "LRS"       # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind                    = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, StorageV2
  https_traffic_only_enabled      = true        # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false       # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false       # SECURITY: Disable Shared Key Access in favour of Entra ID authorisation. 
  lifecycle {
    precondition {
      condition     = length(azurerm_resource_group.mgt_logs.name) <= 24
      error_message = "Storage Account names must be equal to, or less than 24 characters total."
    }
  }
}
