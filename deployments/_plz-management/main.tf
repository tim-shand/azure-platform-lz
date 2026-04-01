#====================================================================================#
# Management: Logging and Monitoring
# Description: 
# - Deploy resources for centralised log collection and monitoring. 
# - Deploy Storage Account for log archiving.    
#====================================================================================#

# GENERAL ------------------------------------------------------------------ #

# Naming: Generate naming convention, pre-determined values and format. 
module "naming" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Group
resource "azurerm_resource_group" "mgt" {
  name     = module.naming.resource_group
  location = var.global.location.primary
  tags     = local.tags_merged
}

# LOGGING ------------------------------------------------------------------ #

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "mgt" {
  name                = module.naming.log_analytics_workspace
  resource_group_name = azurerm_resource_group.mgt.name
  location            = azurerm_resource_group.mgt.location
  tags                = local.tags_merged
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
}

# Data Collection Endpoint: Required for Azure Monitor Agent-based data collection (modern, agentless-friendly).
resource "azurerm_monitor_data_collection_endpoint" "mgt" {
  name                = module.naming.data_collection_endpoint
  resource_group_name = azurerm_resource_group.mgt.name
  location            = azurerm_resource_group.mgt.location
  tags                = local.tags_merged
}
