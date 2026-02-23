#====================================================================================#
# Governance: General
# Description: 
# - Create Resource Group for general Governance stack resources. 
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_gov" {
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = var.global.naming.workload_project
  stack_or_env = var.stack.naming.workload_code # Static suffix for Management Groups. 
}

# Resource Group: Governance - Contain logging related resources.  
resource "azurerm_resource_group" "gov" {
  name     = "${module.naming_gov.full_name}-rg"
  location = var.global.location.primary
  tags     = local.tags_merged
}
