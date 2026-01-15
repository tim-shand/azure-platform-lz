# Stack: Governance [Main] ----------------------------------#

locals {
  prefix            = "${var.naming.prefix}-${var.naming.project}-${var.stack_code}" # Pre-configure resource naming. 
  tags_merged       = merge(var.tags, { Stack = "${var.stack_name}" })
  plz_log_analytics = "${prefix}-law"
}

# Governance: Resource Group, Storage, Global Table
resource "azurerm_resource_group" "plz_gov_rg" {
  name     = "${local.prefix}-rg"
  location = var.global.location
  tags     = local.tags_merged
}

module "plz_gov_sa" {
  source               = "../../modules/gen-secure-storage-account"
  storage_account_name = "${prefix}-sa"

}

# Governance: Management Groups
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

