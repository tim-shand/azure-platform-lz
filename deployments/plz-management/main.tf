#====================================================================================#
# Management: General
# Description: 
# - Create Resource Group for stack resources.    
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mgt_logs" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = "mgt" # Primary category for naming format. 
  category      = "log" # Secondary category for naming format. 
  ensure_unique = true
}

module "naming_mgt_alerts" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = "mgt" # Primary category for naming format. 
  category      = "alt" # Secondary category for naming format. 
  ensure_unique = true
}

# Resource Group: Logging - Contain logging related resources.  
resource "azurerm_resource_group" "mgt_logs" {
  name     = "${module.naming_mgt_logs.full_name}-rg"
  location = var.global.location.primary
  tags     = local.tags_merged
}

# Resource Group: Alerts - Contain alert and action group resources.  
resource "azurerm_resource_group" "mgt_alerts" {
  name     = "${module.naming_mgt_alerts.full_name}-rg"
  location = var.global.location.primary
  tags     = local.tags_merged
}

