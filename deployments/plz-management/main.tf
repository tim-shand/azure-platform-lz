#====================================================================================#
# Management: General
# Description: 
# - Create Resource Group for stack resources.    
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mgt" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Group: Logging - Contain logging related resources.  
resource "azurerm_resource_group" "mgt" {
  name     = "${module.naming_mgt.full_name}-rg"
  location = var.global.location.primary
  tags     = local.tags_merged
}
