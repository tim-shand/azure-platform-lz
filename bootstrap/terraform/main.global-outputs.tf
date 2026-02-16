#====================================================================================#
# Bootstrap: Global Outputs (Shared Services)
# Description: 
# - Creates Azure Application Configuration to hold key/value pairs. 
# - Contains resource IDs and names for accessing shared services in deployment stacks.  
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_globals" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = "platform"
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# App Configuration: Used to store key/value pairs for Shared Service (global) resources (IDs/Names). 
resource "azurerm_app_configuration" "iac" {
  name                     = "${module.naming_globals.full_name}-globals-cfg"
  resource_group_name      = azurerm_resource_group.backend["platform"].name
  location                 = azurerm_resource_group.backend["platform"].location
  sku                      = "free"
  public_network_access    = "Enabled"
  purge_protection_enabled = false
  tags                     = local.tags_merged
  depends_on               = [azuread_application.iac_sp] # Requires RBAC to be assigned first. 
}

# Global Output: Service Principal AppID
resource "azurerm_app_configuration_key" "sp_appid" {
  configuration_store_id = azurerm_app_configuration.iac.id
  key                    = var.global_outputs.iac.iac_service_principal_appid # See mapping in 'global.tfvars'. 
  value                  = azuread_service_principal.iac_sp.client_id         # Add SP client ID to global output key/value. 
  label                  = var.global_outputs.iac.label                       # Related label used to identify entries. 
}

# Global Output: Service Principal Name
resource "azurerm_app_configuration_key" "sp_name" {
  configuration_store_id = azurerm_app_configuration.iac.id
  key                    = var.global_outputs.iac.iac_service_principal_name # See mapping in 'global.tfvars'. 
  value                  = azuread_application.iac_sp.display_name           # Add SP name to global output key/value. 
  label                  = var.global_outputs.iac.label                      # Related label used to identify entries. 
}
