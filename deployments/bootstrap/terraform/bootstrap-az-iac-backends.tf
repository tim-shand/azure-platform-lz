#=================================================================#
# Bootstrap: Azure - Iac Backend Resources (RG, SA, Containers)
#=================================================================#

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
  source               = "../../../modules/storage-account-secure"
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

# RBAC ---------------------------------------------------------------|
# Service Principal: Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_sp_rg" {
  for_each             = local.stacks_by_category
  scope                = azurerm_resource_group.iac_rg[each.key].id # Must be assigned on the resource plane, cannot be inherited from MG. 
  role_definition_name = "Storage Blob Data Contributor"            # Required to access and update blob storage properties. 
  principal_id         = azuread_service_principal.entra_iac_sp.object_id
}

# Current Global Admin User: Required when 'shared_access_key_enabled=false'. 
resource "azurerm_role_assignment" "rbac_ga_rg" {
  for_each             = local.stacks_by_category
  scope                = azurerm_resource_group.iac_rg[each.key].id # Must be assigned on the resource plane, cannot be inherited from MG.
  role_definition_name = "Storage Blob Data Contributor"            # Required to access and update blob storage properties. 
  principal_id         = data.azuread_client_config.current.object_id
}
