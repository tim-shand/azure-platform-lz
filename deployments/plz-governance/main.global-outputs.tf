#====================================================================================#
# Governance: Global Outputs / Shared Services
# Description: 
# - Add resource IDs and names to Global Outputs registry.  
# - These can be referenced by future deployment stacks. 
#====================================================================================#

# Management Group (Core)
resource "azurerm_app_configuration_key" "mg_core_id" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.plz_core_mg_id # Refer to variable in globals.
  value                  = azurerm_management_group.core["core"].id
  depends_on             = [azurerm_management_group.core]
}

resource "azurerm_app_configuration_key" "mg_core_name" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.plz_core_mg_name # Refer to variable in globals.
  value                  = azurerm_management_group.core["core"].name
  depends_on             = [azurerm_management_group.core]
}
