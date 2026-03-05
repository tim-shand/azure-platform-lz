#====================================================================================#
# Bootstrap: Management Group (Core)
# Description: 
# - Creates core (top-level)  Management Group.
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_mg" {
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = var.management_group_core.name # Management Group short name. 
  stack_or_env = "mg"                           # Static suffix for Management Groups. 
}

# Management Group: Core
resource "azurerm_management_group" "core" {
  name         = module.naming_mg.full_name             # Use naming module to produce MG name format. 
  display_name = var.management_group_core.display_name # Diplay name of the core Management Group.   
}
