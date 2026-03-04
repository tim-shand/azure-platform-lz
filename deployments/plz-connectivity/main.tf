#====================================================================================#
# Connectivity: General
# Description: 
# - Create Resource Group for general Connectivity stack resources. 
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_hub" {
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = var.global.naming.workload_project
  stack_or_env = var.stack.naming.workload_code # Static suffix for Management Groups. 
}

# Resource Group for Connectivity resources.
resource "azurerm_resource_group" "hub" {
  name     = ""
  location = ""
}
