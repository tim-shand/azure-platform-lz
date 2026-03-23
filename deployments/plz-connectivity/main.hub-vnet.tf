#====================================================================================#
# Connectivity: Hub VNet
# Description: 
# - Create VNet for centralized hub connectivity.
#====================================================================================#

# VNet: Hub
resource "azurerm_virtual_network" "hub" {
  name                = "${module.naming_con.full_name}-vnet"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  address_space       = var.vnet_hub_cidr
}
