#====================================================================================#
# Governance: Global Outputs / Shared Services
# Description: 
# - Add resource IDs and names to Global Outputs registry.  
# - These can be referenced by future deployment stacks. 
#====================================================================================#

# Management Group (Platform)
resource "azurerm_app_configuration_key" "mg_platform_id" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.platform_mg_id # Refer to variable in globals.
  value                  = azurerm_management_group.level1["platform"].id
  label                  = var.global_outputs.governance.label # Related label used to identify entries. 
  depends_on             = [azurerm_management_group.level1]
}

resource "azurerm_app_configuration_key" "mg_platform_name" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.platform_mg_name # Refer to variable in globals.
  value                  = azurerm_management_group.level1["platform"].name
  label                  = var.global_outputs.governance.label # Related label used to identify entries. 
  depends_on             = [azurerm_management_group.level1]
}

# Policy Initiatives
resource "azurerm_app_configuration_key" "policy_diag_plz_name" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.governance.policy_diag_plz_name # Refer to variable in globals.
  value                  = azurerm_management_group_policy_set_definition.custom["diagnostic_settings"].name
  label                  = var.global_outputs.governance.label # Related label used to identify entries. 
}
