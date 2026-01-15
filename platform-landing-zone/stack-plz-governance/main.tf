# Stack: Governance [Main] ----------------------------------#

# Governance: Management Groups
# Used to manage subscription and policy assignment hierarchy. 
module "plz-gov-management-groups" {
  source                = "../../modules/plz-gov-management-groups"
  naming                = var.naming                # Global naming methods. 
  management_group_root = var.management_group_root # Top level management group name (parent). 
  management_group_list = var.management_group_list # List of management groups and subscriptions to associate. 
}

# Governance: Policies - Generate Custom Definitions
module "plz-gov-policy-definitions" {
  source                 = "../../modules/plz-gov-policy-definitions"
  naming                 = var.naming                                     # Global naming methods. 
  stack_code             = var.stack_code                                 # Used for naming (gov, sec, con).                             
  management_group_keys  = module.plz-gov-management-groups.mg_child_keys # Used to filter JSON files based on scope (core, workload, dev etc). 
  management_group_root  = var.management_group_root                      # Pass in root management group details. 
  policy_custom_def_path = "${path.module}/policy_definitions"            # Location of policy definition files. 
}

# Goverance: Assign Builtin Policy Initiatives
# Use provided variable value to assign a built-in policy initiative. 
data "azurerm_policy_set_definition" "builtin" {
  for_each     = var.policy_builtin_initiatives # Loop each string value in variable to get data on policy initiative. 
  display_name = each.key
}

resource "azurerm_management_group_policy_assignment" "builtin_core" {
  for_each             = data.azurerm_policy_set_definition.builtin # For each policy initiative in the data call. 
  name                 = each.key
  display_name         = "[${upper(var.stack_code)}] Built-In - ${each.key}"
  description          = each.value.description
  policy_definition_id = data.azurerm_policy_set_definition.builtin[each.key].id
  management_group_id  = module.plz-gov-management-groups.mg_root.id # Where to assign the initiative (core). 
  enforce              = var.policy_builtin_initiative_enforce       # True/False
}
