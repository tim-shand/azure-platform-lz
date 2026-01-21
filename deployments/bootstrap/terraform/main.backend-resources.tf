#=================================================================#
# Bootstrap: Azure - Iac Backend Resources (RG, SA, Containers)
#=================================================================#

# Resource Groups ----------------------------------------------------|
# Create separate Resource Groups per deployment category (bootstrap, platform, workloads). 
resource "azurerm_resource_group" "iac_rg" {
  for_each = local.stacks_by_category
  name     = "rg-${module.naming_bootstrap.full_name}-${each.key}"
  location = var.global.locations.default
  tags     = local.tags_merged
}

module "iac_sa" {
  for_each             = local.stacks_by_category
  source               = "../../../modules/global-storage-account-secure"
  storage_account_name = "sa${module.naming_bootstrap.short_name}${each.key}"
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
