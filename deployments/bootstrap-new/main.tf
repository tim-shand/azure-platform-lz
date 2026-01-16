locals {
  # Scan all stacks --> discover categories --> regroup stacks under each category. 
  # - key   = Category name ("bootstrap", "platform", "workloads"). 
  # - value = Map of stacks that belong to that category. 
  stacks_by_category = {
    for c in distinct([                           # Iterate once for each unique category value found in deployment_stacks. 
      for s in var.deployment_stacks : s.category # Loop over all stacks, extract only "category" field from each stack. 
      ]) : c => {                                 # Use the category name as the key in a new map
      for k, s in var.deployment_stacks :         # Loop over all stacks again (key = stack key, s = stack object). 
      k => s if s.category == c                   # Add current stack to the map ONLY IF its category matches the outer loop category (c). 
    }
  }

  # Tags: Merge global with deployment. 
  tags_merged = var.tags != null ? merge(var.tags, var.global.tags) : var.global.tags
}

# Deployment Naming ----------------------------------------------------|
# Generate uniform, consistent name outputs to be used with resources.  
module "naming_bootstrap" {
  source     = "../../modules/global-resource-naming"
  org_prefix = var.global.naming.org_prefix
  project    = var.naming.stack_code
}

# Resource Groups ----------------------------------------------------|
# Create separate Resource Groups per deployment category (bootstrap, platform, workloads). 
resource "azurerm_resource_group" "iac_rg" {
  for_each = local.stacks_by_category
  name     = "${module.naming_bootstrap.full}-${each.key}-rg"
  location = var.global.locations.default
  tags     = local.tags_merged
}

module "iac_sa" {
  for_each             = local.stacks_by_category
  source               = "../../modules/storage-account-secure"
  storage_account_name = "${module.naming_bootstrap.short}${each.key}sa"
  resource_group_name  = azurerm_resource_group.iac_rg[each.key].name
  location             = azurerm_resource_group.iac_rg[each.key].location
  tags                 = local.tags_merged
}

resource "azurerm_storage_container" "iac_cn" {
  for_each              = var.deployment_stacks
  name                  = "tfstate-${each.value.stack_name}"
  storage_account_id    = module.iac_sa[each.value.category].id
  container_access_type = "private"
}
