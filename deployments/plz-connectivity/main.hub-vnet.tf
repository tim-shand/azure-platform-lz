#====================================================================================#
# Connectivity: Hub VNet
# Description: 
# - Create VNet for centralized hub connecitivity.
# - Create subnets for firewall, bastion, gateway and management. 
#====================================================================================#

# Hub: VNet
resource "azurerm_virtual_network" "hub" {
  name                = "${module.naming_con.full_name}-vnet"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  address_space       = var.vnet_hub_cidr
}

# Hub: Subnets
resource "azurerm_subnet" "hub" {
  for_each             = local.hub_services_enabled # Only create for enabled subnets. 
  name                 = lower("hub-subnet-${each.key}")
  resource_group_name  = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.subnet
}
