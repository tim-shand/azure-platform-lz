#============================================#
# Platform LZ: Main Deployment
#============================================#

# Set globally used local variables.
locals {
  prefix = "${var.naming.org}-${var.naming.service}" # Default naming prefix. 
}

# Stack: Governance ----------------------------------#
module "plz_governance" {
  source                    = "../../../modules/azure/azure-plz-governance"
  location                  = var.location
  naming                    = var.naming
  tags                      = var.tags
  gov_management_group_root = var.gov_management_group_root
  gov_management_group_list = var.gov_management_group_list
}

