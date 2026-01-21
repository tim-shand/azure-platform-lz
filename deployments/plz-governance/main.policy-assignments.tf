#=====================================================#
# Platform LZ: Governance - Policy Assignments
#=====================================================#

# Naming: Generate uniform, consistent name outputs to be used with resources. 
module "naming_policy_initiative_builtin" {
  source   = "../../modules/global-naming"
  sections = ["${var.naming.stack_name}", "BuiltIn"]
}

# Policies: Builtin Initiatives - Assign built-in policy initiatives provided by list of display names to target management group.  
module "policy_initiatives_builtin" {
  count                      = var.policy_initiatives_builtin_enable ? 1 : 0 # Enable policy assignment (turns it on/off). 
  source                     = "../../modules/gov-policy-initiatives-builtin"
  naming_prefix              = module.naming_policy_initiative_builtin # Pass in naming prefix for policy initiative display names. 
  builtin_initiatives        = var.policy_initiatives_builtin          # List of builtin initiative display names. 
  enforce                    = var.policy_initiatives_builtin_enforce  # Enforce policy controls (audit vs enforce).
  target_management_group_id = module.management_groups.mg_root_id     # Target management group for assignment. 
}

# # Governance: Policies - Custom Definitions
# # Build custom policy definitions from individual JSON files. 
# module "gov_policy_definitions_custom" {
#   source                 = "../../modules/policy-definitions-custom"
#   naming                 = module.naming                       # Provide naming methods.
#   stack_code             = var.naming.stack_code               # Used in display names. 
#   policy_custom_def_path = "${path.module}/policy_definitions" # Location of policy definition files. 
# }

# # Governance: Policies - Custom Initiatives
# # Assign built-in policy initiatives provided by list of display names to target management group.  
# module "gov_policy_initiatives_custom" {
#   source        = "../../modules/policy-initiatives-custom"
#   naming        = module.naming
#   stack_code    = var.naming.stack_code # Used in display names. 
#   policy_groups = local.policy_groups   # Pass in local map of  
# }
