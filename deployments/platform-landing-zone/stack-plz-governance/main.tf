# Stack: Governance [Main] ----------------------------------#

# Deployment Naming
# Generate uniform, consistent name outputs to be used with resources.  
module "naming" {
  source     = "../../../modules/global-resource-naming"
  org_prefix = var.global.naming.org_prefix
  project    = var.global.naming.project_short
  category1  = var.naming.stack_code
}

# Governance: Management Groups
# Deploy opinionated management group hierarchy. Assign subscriptions based on identifiers. 
module "gov_management_groups" {
  source                = "../../../modules/mg-sub-assignments"
  naming                = module.naming             # Provide naming methods. 
  management_group_root = var.management_group_root # Top level management group name (parent).  
  subscription_prefixes = var.subscription_prefixes # Mapping management groups and subscriptions. 
}

# Governance: Policies - Builtin Initiatives
# Assign built-in policy initiatives provided by list of display names to target management group.  
module "gov_policy_initiatives_builtin" {
  count                      = var.policy_initiatives_builtin_enable ? 1 : 0 # Enable policy assignment (turns it on/off). 
  source                     = "../../../modules/policy-initiatives-builtin"
  naming                     = module.naming
  builtin_initiatives        = var.policy_initiatives_builtin          # List of builtin initiative display names. 
  enforce                    = var.policy_initiatives_builtin_enforce  # Enforce policy controls (audit vs enforce).
  target_management_group_id = module.gov_management_groups.mg_root.id # Target management group for assignment. 
}

# Governance: Policies - Custom Definitions
# Build custom policy definitions from individual JSON files. 
module "gov_policy_definitions_custom" {
  source                 = "../../../modules/policy-definitions-custom"
  naming                 = module.naming                       # Provide naming methods.
  stack_code             = var.naming.stack_code               # Used in display names. 
  policy_custom_def_path = "${path.module}/policy_definitions" # Location of policy definition files. 
}

# Governance: Policies - Custom Initiatives
# Assign built-in policy initiatives provided by list of display names to target management group.  
module "gov_policy_initiatives_custom" {
  source        = "../../../modules/policy-initiatives-custom"
  naming        = module.naming
  stack_code    = var.naming.stack_code # Used in display names. 
  policy_groups = local.policy_groups   # Pass in local map of  
}

# Governance: Policies - Custom Assignments
resource "azurerm_management_group_policy_assignment" "core" {
  name                 = "gov-policy-core"
  management_group_id  = module.gov_management_groups.mg_root.id
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["core"]
}
resource "azurerm_management_group_policy_assignment" "platform" {
  name                 = "gov-policy-platform"
  management_group_id  = module.gov_management_groups.mg_platform
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["platform"]
}
resource "azurerm_management_group_policy_assignment" "workloads" {
  name                 = "gov-policy-workloads"
  management_group_id  = module.gov_management_groups.mg_workloads
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["workloads"]
}
resource "azurerm_management_group_policy_assignment" "workloads_prd" {
  name                 = "gov-policy-workloads-prd"
  management_group_id  = module.gov_management_groups.mg_workloads_prd
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["workloads_prd"]
}
resource "azurerm_management_group_policy_assignment" "workloads_dev" {
  name                 = "gov-policy-workloads-dev"
  management_group_id  = module.gov_management_groups.mg_workloads_dev
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["workloads_dev"]
}
resource "azurerm_management_group_policy_assignment" "sandbox" {
  name                 = "gov-policy-sandbox"
  management_group_id  = module.gov_management_groups.mg_sandbox
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["sandbox"]
}
resource "azurerm_management_group_policy_assignment" "decom" {
  name                 = "gov-policy-decom"
  management_group_id  = module.gov_management_groups.mg_decommissioned
  policy_definition_id = module.gov_policy_initiatives_custom.initiatives["decommissioned"]
}
