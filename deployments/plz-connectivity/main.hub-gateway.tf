#====================================================================================#
# Connectivity: Hub VPN Gateway
# Description: 
# - VPN Gateway service for on-prem to cloud connectivity. 
#====================================================================================#

# Public IP: Gateway
resource "azurerm_public_ip" "gw" {
  count               = var.hub_gateway.enabled ? 1 : 0
  name                = "${module.naming_con.full_name}-bas-pip"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Subnet: Gateway
resource "azurerm_subnet" "gw" {
  count                           = var.hub_gateway.enabled ? 1 : 0 # Only create if enabled.
  name                            = "GatewaySubnet"                 # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = var.hub_gateway.subnet
  default_outbound_access_enabled = true # Required for Bastion services to operate correctly. # Disable to prevent outbound Internet via subnet (force gateway).
}

# Gateway: VNet Gateway
resource "azurerm_virtual_network_gateway" "gw" {
  count               = var.hub_gateway.enabled ? 1 : 0
  name                = "${module.naming_con.full_name}-vgw"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  type                = var.hub_gateway.type
  sku                 = var.hub_gateway.sku
  vpn_type            = "RouteBased"
  ip_configuration {
    name                          = "ipconfig-hub-gateway"
    public_ip_address_id          = azurerm_public_ip.gw.ip_address
    private_ip_address_allocation = "Dynamic" # The only valid value is Dynamic (Static is not supported by the service yet).
    subnet_id                     = azurerm_subnet.gw.id
  }
}
