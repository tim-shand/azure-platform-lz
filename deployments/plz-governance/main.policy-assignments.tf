#====================================================================================#
# Governance: Policy Assignments
# Description: 
# - Assign policy initiatives to Management Groups.  
# - Definition -> Initiative -> Assignment -> Scope
#====================================================================================#

module "naming_policy_assign" {
  for_each      = local.mg_initiative_pairs
  source        = "../../modules/global-resource-naming"
  prefix        = var.stack.naming.workload_code # gov
  workload      = each.key                       # Management Group key names. 
  stack_or_env  = "asn"                          # Any value representing an assignment. 
  ensure_unique = true                           # Randomize the name. 
}

# CUSTOM: Assign Policy Definitions to mapped Management Groups. 
resource "azurerm_management_group_policy_assignment" "custom" {
  for_each             = local.mg_initiative_pairs                                 # Loop for each of the keys in the flattend map. 
  name                 = module.naming_policy_assign[each.key].compact_name_unique # Get name from naming module (limit 24 chars). 
  display_name         = "[${upper(var.stack.naming.workload_code)}] ${title(replace(each.value.initiative, "_", " "))} Assignment"
  management_group_id  = data.azurerm_management_group.lookup[each.value.mg_name].id                     # Perform lookup on MG ID using data call with current value. 
  policy_definition_id = azurerm_management_group_policy_set_definition.custom[each.value.initiative].id # Use the ID of the initiative. 
  enforce              = var.policy_enforce_mode                                                         # Enforce mode (true/false), set in TFVARS. 
  parameters = jsonencode({
    for k, v in try(local.initiative_assignment_parameters[each.value.initiative], {}) :
    k => { value = v } if v != null # Pass initiative specific parameters only. Fallback to empty map if initiative has no parameters.
  })
}
