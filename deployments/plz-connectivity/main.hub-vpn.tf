#====================================================================================#
# Connectivity: Hub VPN Gateway
# Description: 
# - VPN Gateway service for on-prem to cloud connectivity. 
#====================================================================================#

# NOTICE: Note on use of VPN Gateway:
# This requires a Pre-Shared Key to be added to the GitHub Actions Secrets at the repo level.
# The PSK is then passed in via the workflow, preventing key leakage into the code base.
# Add the PSK to your VPN device and then update the GitHub Actions Secret "VPN_LOCAL_PSK".
# Add the VPN device public IP to the GitHub Actions Variable "VPN_PUBLIC_IP".

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
resource "azurerm_local_network_gateway" "onprem" {
  count               = var.hub_vpn.enabled ? 1 : 0
  name                = "${module.naming_con.gateway_local}-onprem"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  gateway_address     = var.hub_vpn.local_public_ip # On-prem public IP (123.1.2.3)
  address_space       = var.hub_vpn.local_address_spaces # On-prem IP address space ["10.0.0.0/16"].
}

# CONNECTION --------------------------------------------- #

resource "azurerm_virtual_network_gateway_connection" "onprem" {
  count                      = var.hub_vpn.enabled ? 1 : 0
  name                       = "${module.naming.connection}-onprem"
  resource_group_name        = azurerm_resource_group.con.name
  location                   = azurerm_resource_group.con.location
  tags                       = local.tags_merged
  type                       = var.hub_vpn.connection_type
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem[0].id
  shared_key                 = var.vpn_local_psk
  connection_protocol        = var.hub_vpn.connection_protocol # IKEv1, IKEv2
  ipsec_policy {
    ike_encryption   = var.hub_vpn.ipsec_policy.ike_encryption
    ike_integrity    = var.hub_vpn.ipsec_policy.ike_integrity
    dh_group         = var.hub_vpn.ipsec_policy.dh_group
    ipsec_encryption = var.hub_vpn.ipsec_policy.ipsec_encryption
    ipsec_integrity  = var.hub_vpn.ipsec_policy.ipsec_integrity
    pfs_group        = var.hub_vpn.ipsec_policy.pfs_group
    sa_lifetime      = var.hub_vpn.ipsec_policy.sa_lifetime
    sa_datasize      = var.hub_vpn.ipsec_policy.sa_datasize
  }
}
