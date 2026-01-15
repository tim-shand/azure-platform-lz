#=====================================================#
# General: Storage Account (Secure)
#=====================================================#

locals {
  sa_name_max_length    = 24                       # Used to automatically modify Storage Account names to fit naming restrictions. 
  sa_name_random_length = 6                        # Set length of random string to use with Storage Account naming.
  storage_account_name  = var.storage_account_name # Pass in desired name of storage account. 
}


# Generate a random integer to use for suffix uniqueness in Storage Account naming. 
resource "random_integer" "rndint" {
  min = 100000
  max = 999999
}

# Storage Account ----------------------------------------------------|
resource "azurerm_storage_account" "iac_sa" {
  name                            = length(each.value.storage_account_name) > local.sa_name_max_length ? "${substr("${each.value.storage_account_name}", 0, local.sa_name_max_length - local.sa_name_random_length)}${random_integer.rndint.result}" : "${each.value.storage_account_name}"
  resource_group_name             = azurerm_resource_group.iac_rg[each.key].name
  location                        = azurerm_resource_group.iac_rg[each.key].location
  tags                            = azurerm_resource_group.iac_rg[each.key].tags
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true  # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false # SECURITY: Disable Shared Key Access in favour of Entra ID authorisation. 
  #public_network_access_enabled   = false # TEST: Disable public network access. Changes needed to allow GitHub runners. 
  lifecycle {
    precondition {
      condition     = length(each.value.storage_account_name) < local.sa_name_max_length
      error_message = "Storage Account must be less than 24 characters total."
    }
  }
}
