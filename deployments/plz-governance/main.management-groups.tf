#====================================================================================#
# Governance: Management Groups
# Description: 
# - Create Management Group structure.  
# - Assign subscriptions to Management Groups.  
#====================================================================================#

# Shared Services: Add Core Management Group to IaC Key Vault. 
resource "azurerm_key_vault_secret" "mg_root" {
  name         = var.shared_services.management_group_core
  value        = data.azurerm_management_group.core.name
  key_vault_id = data.azurerm_key_vault.iac_kv.id # Key Vault created during bootstrap for shared services. 
  tags         = local.tags_merged
  content_type = "ResourceName" # Helpful hint to what the value is. 
  lifecycle {
    ignore_changes = [value] # Prevent Terraform from trying to recreate a secret version if concurrent applies happen. 
  }
}

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mg_level1" {
  for_each     = var.management_groups_level1
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = each.key
  stack_or_env = "mg"
}

module "naming_mg_level2" {
  for_each     = var.management_groups_level2
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = each.key
  stack_or_env = "mg"
}

module "naming_mg_level3" {
  for_each     = var.management_groups_level3
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = each.key
  stack_or_env = "mg"
}

# Management Groups: Level 1
resource "azurerm_management_group" "level1" {
  for_each                   = var.management_groups_level1
  name                       = module.naming_mg_level1[each.key].full_name                       # Use naming module to produce MG name format. 
  display_name               = title(var.management_groups_level1[each.key].display_name)        # Use map key for MG display name.   
  subscription_ids           = lookup(local.management_group_subscriptions_level1, each.key, []) # Assign mapped subscriptions from locals. 
  parent_management_group_id = data.azurerm_management_group.core.id                             # Assign to top-level MG created during bootstrap.
}

# Management Groups: Level 2
resource "azurerm_management_group" "level2" {
  for_each                   = var.management_groups_level2
  name                       = module.naming_mg_level2[each.key].full_name                       # Use naming module to produce MG name format.  
  display_name               = title(var.management_groups_level2[each.key].display_name)        # Use map key for MG display name.        
  subscription_ids           = lookup(local.management_group_subscriptions_level2, each.key, []) # Assign mapped subscriptions from locals. 
  parent_management_group_id = local.management_group_ids_level2[each.value.parent_mg_name]      # Assign to level 1 parent management group.
}

# Management Groups: Level 3
resource "azurerm_management_group" "level3" {
  for_each                   = var.management_groups_level3
  name                       = module.naming_mg_level3[each.key].full_name                       # Use naming module to produce MG name format. 
  display_name               = title(var.management_groups_level3[each.key].display_name)        # Use map key for MG display name.        
  subscription_ids           = lookup(local.management_group_subscriptions_level3, each.key, []) # Assign mapped subscriptions from locals.  
  parent_management_group_id = local.management_group_ids_level3[each.value.parent_mg_name]      # Assign to level 2 parent management group.
}
