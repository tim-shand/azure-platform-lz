#=====================================================#
# Module: Storage Account (Secure)
#=====================================================#

locals {
  sa_name_max_length    = 24 # Used to automatically modify Storage Account names to fit naming restrictions. 
  sa_name_random_length = 6  # Set length of random string to use with Storage Account naming.
  # Pass in desired name of storage account. Remove illegal characters and add a random suffix. 
  storage_account_name = lower(replace("${var.storage_account_name}${random_string.rndstr.result}", "/[^a-z0-9]/", ""))
}

resource "random_string" "rndstr" {
  length  = local.sa_name_random_length
  upper   = false
  lower   = false
  numeric = true
  special = false
}

# Storage Account ----------------------------------------------------|
resource "azurerm_storage_account" "main" {
  name                            = length(local.storage_account_name) > local.sa_name_max_length ? "${substr("${local.storage_account_name}", 0, local.sa_name_max_length - local.sa_name_random_length)}${random_string.rndstr.result}" : "${local.storage_account_name}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tags                            = var.tags
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  https_traffic_only_enabled      = true  # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false # SECURITY: Disable Shared Key Access in favour of Entra ID authorisation. 
  #public_network_access_enabled   = false # TEST: Disable public network access. Changes needed to allow GitHub runners. 
  # lifecycle {
  #   precondition {
  #     condition     = length(local.storage_account_name) < local.sa_name_max_length
  #     error_message = "Storage Account must be less than 24 characters total."
  #   }
  # }
}

# tjsbootstrapiacplz384167
