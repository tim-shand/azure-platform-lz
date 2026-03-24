#====================================================================================#
# Connectivity: Global Outputs / Shared Services
# Description: 
# - Add resource IDs and names to Global Outputs registry.  
# - These can be referenced by future deployment stacks. 
#====================================================================================#

# Hub VNet: Name
resource "azurerm_app_configuration_key" "hub_vnet_name" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.connectivity.hub_vnet_name # Refer to variable in globals.
  value                  = azurerm_virtual_network.hub.name
  label                  = var.global_outputs.connectivity.label # Related label used to identify entries. 
}

# Hub VNet: Resource Group Name
resource "azurerm_app_configuration_key" "hub_vnet_rg" {
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.connectivity.hub_vnet_resource_group # Refer to variable in globals.
  value                  = azurerm_virtual_network.hub.resource_group_name
  label                  = var.global_outputs.connectivity.label # Related label used to identify entries. 
}

# Hub Firewall: Name
resource "azurerm_app_configuration_key" "hub_fwl_name" {
  count                  = var.hub_firewall.enabled ? 1 : 0
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.connectivity.firewall_name # Refer to variable in globals.
  value                  = azurerm_firewall.hub.name
  label                  = var.global_outputs.connectivity.label # Related label used to identify entries. 
}

# Hub Firewall: Resource Group Name
resource "azurerm_app_configuration_key" "hub_fwl_rg" {
  count                  = var.hub_firewall.enabled ? 1 : 0
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.connectivity.firewall_resource_group # Refer to variable in globals.
  value                  = azurerm_firewall.hub.resource_group_name
  label                  = var.global_outputs.connectivity.label # Related label used to identify entries. 
}

# Hub Gateway: Name
resource "azurerm_app_configuration_key" "hub_vgw_name" {
  count                  = var.hub_gateway.enabled ? 1 : 0
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.connectivity.gateway_name # Refer to variable in globals.
  value                  = azurerm_virtual_network_gateway.vgw.name
  label                  = var.global_outputs.connectivity.label # Related label used to identify entries. 
}

# Hub Gateway: Resource Group Name
resource "azurerm_app_configuration_key" "hub_vgw_rg" {
  count                  = var.hub_gateway.enabled ? 1 : 0
  provider               = azurerm.iac # Use aliased provider to access IaC subscription. 
  configuration_store_id = data.azurerm_app_configuration.iac.id
  key                    = var.global_outputs.connectivity.gateway_resource_group # Refer to variable in globals.
  value                  = azurerm_virtual_network_gateway.vgw.resource_group_name
  label                  = var.global_outputs.connectivity.label # Related label used to identify entries. 
}
