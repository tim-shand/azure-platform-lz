# Stack: Governance [Main] ----------------------------------#

# Governance: Management Groups
module "plz-gov-management-groups" {
  source                = "../../modules/plz-gov-management-groups"
  naming                = var.naming
  management_group_root = var.management_group_root # Top level management group name (parent). 
  management_group_list = var.management_group_list # List of management groups and subscriptions to associate. 
}

# Governance: Policies - Custom Definitions
module "plz-gov-policy-definitions" {
  source                 = "../../modules/plz-gov-policy-definitions"
  naming                 = var.naming                          # Global naming methods. 
  stack_code             = var.stack_code                      # Used for naming (gov, sec, con). 
  filter_string          = "Core"                              # Used to filter JSON files based on scope (core, workload, dev etc). 
  policy_custom_def_path = "${path.module}/policy_definitions" # Location of policy definition files. 
}
