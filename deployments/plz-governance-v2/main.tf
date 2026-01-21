#=====================================================#
# Platform LZ: Governance - Management Groups
#=====================================================#

data "azurerm_subscriptions" "all" {} # Get all subscriptions visible to current identity. 

# Naming: Generate uniform, consistent name outputs to be used with resources. 
module "naming" {
  source     = "../../modules/global-resource-naming"
  org_prefix = var.global.naming.org_prefix
  project    = var.global.naming.project_short
  category1  = var.naming.stack_code
}

# Management Groups: Organisation and hierarchy, contain relevant subscriptions and assign policy. 
module "management-groups" {
  source                   = "../../modules/gov-management-groups"
  global                   = var.global                                   # Global configuration. 
  subscriptions            = data.azurerm_subscriptions.all.subscriptions # Pass in all subscriptions from data call. 
  management_group_root    = var.management_group_root                    # Root: Top-level MG representign the organisation. 
  management_groups_level1 = var.management_groups_level1                 # Level 1: Nested under root MG. 
  management_groups_level2 = var.management_groups_level2                 # Level 2: Nested under level 1 MGs. 
  management_groups_level3 = var.management_groups_level3                 # Level 3: Nested under level 2 MGs. Leave blank "{}" if not required. 
  management_groups_level4 = var.management_groups_level4                 # Level 4: Nested under level 3 MGs. Leave blank "{}" if not required. 
}

