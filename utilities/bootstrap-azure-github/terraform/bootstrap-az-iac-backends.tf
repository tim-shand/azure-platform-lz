#=================================================================#
# Bootstrap: Azure - Iac Backend Resources (RG, SA, Containers)
#=================================================================#

# Generate a random integer to use for suffix uniqueness in Storage Account naming. 
resource "random_integer" "rndint" {
  min = 100000
  max = 999999
}

# Resource Groups ----------------------------------------------------|
# Create separate Resource Groups per deployment category. 
resource "azurerm_resource_group" "iac_rg" {
  for_each = local.resource_stack_mapping
  name     = each.value.resource_group_name
  location = var.global.location
  tags     = var.tags
}

# Storage Accounts ----------------------------------------------------|
# Create separate Storage Accounts per stack category, in their own Resource Groups. 
# INFO: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#arguments-reference
resource "azurerm_storage_account" "iac_sa" {
  for_each                        = local.resource_stack_mapping
  name                            = length(each.value.storage_account_name) > local.sa_name_max_length ? "${substr("${each.value.storage_account_name}", 0, local.sa_name_max_length - local.sa_name_random_length)}${random_integer.rndint.result}" : "${each.value.storage_account_name}"
  resource_group_name             = azurerm_resource_group.iac_rg[each.key].name
  location                        = azurerm_resource_group.iac_rg[each.key].location
  tags                            = azurerm_resource_group.iac_rg[each.key].tags
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true  # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false # Prevent anonymous/public access to Storage Accounts.  
  lifecycle {
    precondition {
      condition     = length(each.value.storage_account_name) < local.sa_name_max_length
      error_message = "Storage Account must be less than 24 characters total."
    }
  }
}

# Blob Containers ----------------------------------------------------|
# Deploy Blob Containers per stack in each category. 
resource "azurerm_storage_container" "iac_cn" {
  for_each              = local.stacks_flat
  name                  = "tfstate-${each.value.stack_name}"
  storage_account_id    = azurerm_storage_account.iac_sa[each.value.category].id
  container_access_type = "private"
}
