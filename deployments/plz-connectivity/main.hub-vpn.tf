#====================================================================================#
# Connectivity: Hub VPN Gateway
# Description: 
# - VPN Gateway service for on-prem to cloud connectivity. 
#====================================================================================#

# NETWORKING -------------------------------------- #

# Public IP: Gateway
resource "azurerm_public_ip" "vpn" {
  count               = var.hub_vpn.enabled ? 1 : 0
  name                = "${module.naming_con.public_ip}-vpn"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Subnet: Gateway
resource "azurerm_subnet" "vpn" {
  count                           = var.hub_vpn.enabled ? 1 : 0 # Only create if enabled.
  name                            = "GatewaySubnet"             # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = [var.hub_vpn.subnets[0]]
  default_outbound_access_enabled = false
}

# VPN GATEWAY -------------------------------------- #

# Gateway: VNet Gateway
resource "azurerm_virtual_network_gateway" "vpn" {
  count               = var.hub_vpn.enabled ? 1 : 0
  name                = module.naming_con.gateway_vpn
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  type                = "Vpn"
  sku                 = var.hub_vpn.sku_tier
  vpn_type            = var.hub_vpn.vpn_type # RouteBased, PolicyBased
  active_active       = contains(["HighPerformance", "UltraPerformance"], var.hub_vpn.sku_tier) ? false : var.hub_vpn.features.active_active
  bgp_enabled         = var.hub_vpn.features.bgp_enabled
  ip_configuration {
    name                          = "ipconfig-hub-vpn-gateway"
    subnet_id                     = azurerm_subnet.vpn[0].id
    public_ip_address_id          = azurerm_public_ip.vpn[0].ip_address
    private_ip_address_allocation = "Dynamic" # The only valid value is Dynamic (Static is not supported by the service yet).
  }
}


# LOCAL NETWORK GATEWAY -------------------------------------- #
# Represents your VPN/firewall device on-prem (example: OPNsense).
# Variables and updated when your ISP changes your IP.

resource "azurerm_local_network_gateway" "onprem" {
  count               = var.hub_vpn.enabled ? 1 : 0
  name                = "${module.naming_con.gateway_local}-onprem"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  gateway_address     = var.hub_vpn.local_public_ip # On-prem public IP.
  address_space       = var.hub_vpn.local_address_spaces # On-prem IP address space.
}
