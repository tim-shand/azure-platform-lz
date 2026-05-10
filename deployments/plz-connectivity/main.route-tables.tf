#====================================================================================#
# Connectivity: Hub Route Tables
# Description: 
# - Provide routing pathways to force traffic via Azure Firewall (if enabled).
#====================================================================================#

# Firewall enabled:
# Route table to force traffic via the Firewall for inspection.
# Every subnet that should have traffic inspected needs a route forcing it through the firewall private IP.

# VPN Gateway enabled:
# Route table on the GatewaySubnet prevents on-prem routes learned via the gateway from propagating to other subnets automatically. 
# Providing explicit control over what on-prem traffic can reach.

# SHARED SUBNET --------------------------------------------------- #

# Route Table: Shared
resource "azurerm_route_table" "shared" {
  name                          = "${module.naming_con.route_table}-shared"
  resource_group_name           = azurerm_resource_group.con.name
  location                      = azurerm_resource_group.con.location
  bgp_route_propagation_enabled = false # Prevent gateway routes propagating into this subnet.
  tags                          = local.tags_merged
}

# Default route to force all traffic through firewall (if enabled).
resource "azurerm_route" "shared_default" {
  count                  = var.hub_firewall.enabled ? 1 : 0
  name                   = "udr_default-to-fw"
  resource_group_name    = azurerm_resource_group.con.name
  route_table_name       = azurerm_route_table.shared.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub[0].ip_configuration[0].private_ip_address
}

# On-prem Route: Sends on-prem traffic through firewall for inspection.
resource "azurerm_route" "shared_onprem" {
  for_each               = var.hub_firewall.enabled ? toset(var.hub_vpn.local_address_spaces) : toset([])
  name                   = "udr_onprem-${replace(each.key, "/", "-")}"
  resource_group_name    = azurerm_resource_group.con.name
  route_table_name       = azurerm_route_table.shared.name
  address_prefix         = each.key
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub[0].ip_configuration[0].private_ip_address
}
# Association: Firewall
resource "azurerm_subnet_route_table_association" "shared" {
  subnet_id      = azurerm_subnet.shared.id
  route_table_id = azurerm_route_table.shared.id
}

# VPN GATEWAY ------------------------------------------------- #

# Route Table: Gateway
resource "azurerm_route_table" "vpn" {
  count                         = var.hub_vpn.enabled ? 1 : 0
  name                          = "${module.naming_con.route_table}-vpn"
  resource_group_name           = azurerm_resource_group.con.name
  location                      = azurerm_resource_group.con.location
  bgp_route_propagation_enabled = false
  tags                          = local.tags_merged
}

# Route Azure VNet traffic through firewall when both firewall and VPN are enabled.
# Ensures on-premises to Azure traffic is inspected.
resource "azurerm_route" "vpn_to_firewall" {
  count                  = var.hub_firewall.enabled && var.hub_vpn.enabled ? 1 : 0
  name                   = "udr_vpn-to-firewall"
  resource_group_name    = azurerm_resource_group.con.name
  route_table_name       = azurerm_route_table.vpn[0].name
  address_prefix         = var.ip_address_space.hub  # Hub VNet address space
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub[0].ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "gateway" {
  count          = var.hub_vpn.enabled ? 1 : 0
  subnet_id      = azurerm_subnet.vpn[0].id
  route_table_id = azurerm_route_table.vpn[0].id
}
