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
