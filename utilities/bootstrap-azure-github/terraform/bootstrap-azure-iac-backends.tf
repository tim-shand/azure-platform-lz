#=================================================================#
# Bootstrap: Azure - Iac Backend Resources (RG, SA, Containers)
#=================================================================#

locals {
  # Configure Storage Account naming. 
  resource_prefix       = "${var.naming.prefix}-${var.naming.service}"
  sa_name_max_length    = 24 # Used to automatically modify Storage Account names to fit naming restrictions. 
  sa_name_random_length = 6  # Set length of random string to use with Storage Account naming. 

  # Map resource groups to create, along with a single storage account name to be created inside of it. 
  resource_stack_mapping = {
    for category, stacks in var.deployment_stacks :
    category => {
      resource_group_name  = "${var.naming.prefix}-${var.naming.service}-${category}-rg"
      storage_account_name = lower("${var.naming.prefix}${var.naming.service}${category}sa${random_integer.rndint.result}")
      stacks = [
        for stack_key, stack in stacks : merge(stack, { stack_key = stack_key })
      ]
    }
  }

  # Flatten stacks across categories for easier for_each iterations. 
  stacks_flat = {
    for item in flatten([
      for category, cat_obj in local.resource_stack_mapping : [ # Iterate each top-level category (platform, workloads). 
        for stack in cat_obj.stacks :                           # Iterates each stack in that category. 
        # Merge top level data with stack data into a new map. 
        merge(stack, { category = category, key = "${category}.${stack.stack_key}" })
      ]
    ]) : item.key => item # Sets the key in the resulting map. 
  }

  # Filter for stacks with configuration where create_github_env = true. 
  github_env_stacks = {
    for k, v in local.stacks_flat : k => v
    if try(v.create_github_env, false)
  }
}

# Generate a random integer to use for suffix uniqueness in Storage Account naming. 
resource "random_integer" "rndint" {
  min = 100000
  max = 999999
}

# Resource Groups:
# Create separate Resource Groups per deployment category. 
resource "azurerm_resource_group" "iac_rg" {
  for_each = local.resource_stack_mapping
  name     = each.value.resource_group_name
  location = var.global.location
  tags     = var.tags
}

# Storage Accounts: 
# Create separate Storage Accounts per stack category, in their own Resource Groups. 
resource "azurerm_storage_account" "iac_sa" {
  for_each                   = local.resource_stack_mapping
  name                       = length(each.value.storage_account_name) > local.sa_name_max_length ? "${substr("${each.value.storage_account_name}", 0, local.sa_name_max_length - local.sa_name_random_length)}${random_integer.rndint.result}" : "${each.value.storage_account_name}"
  resource_group_name        = azurerm_resource_group.iac_rg[each.key].name
  location                   = azurerm_resource_group.iac_rg[each.key].location
  tags                       = azurerm_resource_group.iac_rg[each.key].tags
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true # Enforce secure file transfer. 
  lifecycle {
    precondition {
      condition     = length(each.value.storage_account_name) < local.sa_name_max_length
      error_message = "Storage Account must be less than 24 characters total."
    }
  }
}

# Blob Containers:
# Deploy Blob Containers per stack in each category. 
resource "azurerm_storage_container" "iac_cn" {
  for_each              = local.stacks_flat
  name                  = "tfstate-${each.value.stack_name}"
  storage_account_id    = azurerm_storage_account.iac_sa[each.value.category].id
  container_access_type = "private"
}
