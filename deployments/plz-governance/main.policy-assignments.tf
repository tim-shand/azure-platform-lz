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

# CUSTOM: Assign Policy Initiatives to mapped Management Groups. 
resource "azurerm_management_group_policy_assignment" "custom" {
  for_each             = local.mg_initiative_pairs                                 # Loop for each of the keys in the flattend map. 
  name                 = module.naming_policy_assign[each.key].compact_name_unique # Get name from naming module (limit 24 chars). 
  display_name         = "[${upper(var.stack.naming.workload_code)}] ${title(replace(each.value.initiative, "_", " "))} Assignment"
  management_group_id  = data.azurerm_management_group.lookup[each.value.mg_name].id                     # Perform lookup on MG ID using data call with current value. 
  policy_definition_id = azurerm_management_group_policy_set_definition.custom[each.value.initiative].id # Use the ID of the initiative. 
  enforce              = var.policy_enforce_mode                                                         # Enforce mode (true/false), set in TFVARS. 
  location             = azurerm_user_assigned_identity.policy.location                                  # Must be used when Managed Identity is assigned. 
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.policy.id] # Managed Identity ID for policy. 
  }
  parameters = jsonencode({
    for k, v in try(local.initiative_assignment_parameters[each.value.initiative], {}) :
    k => { value = v } if v != null # Pass initiative specific parameters only. Fallback to empty map if initiative has no parameters.
  })
}

# BUILT-IN: Assign built-in policy initiatives at the provided level (in the variable map, short name resolved in locals). 
resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each = {
    for k, v in var.policy_initiatives_builtin :
    k => v if v.enabled # Only select initiatives that are set to be enabled.
  }
  name                 = each.key
  display_name         = "[${upper(var.stack.naming.workload_code)}] BuiltIn - ${each.key}"
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id # Get from resolved initiative data call. 
  management_group_id  = data.azurerm_app_configuration_key.mg_core_id.value     # Assign directly to core MG. 
  enforce              = each.value.enforce                                      # True/False
  location             = azurerm_user_assigned_identity.policy.location          # Must be used when Managed Identity is assigned. 
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.policy.id] # Managed Identity ID for policy. 
  }
}
