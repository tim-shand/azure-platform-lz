#=====================================================#
# Platform LZ: Governance - Policy Assignments
#=====================================================#

locals {
  # Combine all MG levels into one map. 
  management_groups_all_levels = merge(
    var.management_group_root,
    var.management_groups_level1,
    var.management_groups_level2,
    var.management_groups_level3,
    var.management_groups_level4,
    var.management_groups_level5
  )
  mg_initiative_assignments = { # Create a local variable named "mg_initiative_assignments". 
    #for mg_name, mg_details in var.management_groups_level1 : # Loop over each key-value pair in the input variable "management_groups_level1". 
    for mg_name, mg_details in local.management_groups_all_levels :
    mg_name => [                                        # Use the management group name as the key in the new map. 
      for initiative in mg_details.policy_initiatives : # Loop over each initiative listed for this management group. 
      {                                                 # Build an object for each initiative. 
        initiative = initiative                         # Store the initiative name. 
        mg_name    = mg_name                            # Store the management group name. 
      }
    ]
  }
  # Flatten the nested lists into a single map with unique keys. 
  mg_initiative_assignments_flat = {                                                # Create another local variable called mg_initiative_assignments_flat. 
    for pair in flatten([for mg, list in local.mg_initiative_assignments : list]) : # Flatten all lists of initiatives into a single list and loop over each item. 
    "${pair.mg_name}_${pair.initiative}" => pair                                    # Use a combined key of MG name + initiative name for uniqueness, map to the object "pair". 
  }
}

# Policies: Custom Initiative Assignments
resource "azurerm_management_group_policy_assignment" "custom" {
  for_each             = local.mg_initiative_assignments_flat                                  # For each entry in the flattened local map. 
  name                 = each.key                                                              # Assignment name. 
  management_group_id  = module.management_groups.management_groups_all[each.value.mg_name].id # Target MG for assignment (matching from TFVARS). 
  policy_definition_id = azurerm_policy_set_definition.custom[each.value.initiative].id        # Each initiative in list (see TFVARS). 
  parameters = jsonencode({
    allowedLocations = var.policy_allowed_locations
    requiredTags     = var.policy_required_tags
    skus             = var.policy_allowed_vm_skus
    effect           = "Audit"
  })
}

# Policies: Builtin Initiatives - Assign built-in policy initiatives provided by list of display names to target management group.  
module "policy_initiatives_builtin" {
  source                     = "../../modules/gov-policy-initiatives-builtin"
  count                      = var.policy_initiatives_builtin_enable ? 1 : 0 # Enable policy assignment (turns it on/off). 
  naming_prefix              = var.naming.stack_code                         # Pass in naming prefix for policy initiative display names. 
  builtin_initiatives        = var.policy_initiatives_builtin                # List of builtin initiative display names. 
  enforce                    = var.policy_initiatives_builtin_enforce        # Enforce policy controls (audit vs enforce).
  target_management_group_id = module.management_groups.root_id              # Target management group for assignment. 
}
