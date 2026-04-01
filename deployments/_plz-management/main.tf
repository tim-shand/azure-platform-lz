#====================================================================================#
# Management: Logging and Monitoring
# Description: 
# - Deploy resources for centralised log collection and monitoring. 
# - Deploy Storage Account for log archiving.    
#====================================================================================#

# GENERAL ------------------------------------------------------------------ #

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mgt" {
  source        = "../../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Group: Single RG for all backends.
resource "azurerm_resource_group" "mgt" {
  name     = module.naming_mgt.resource_group
  location = var.global.location.primary
  tags     = local.tags_merged
}
