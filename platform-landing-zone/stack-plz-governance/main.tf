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

