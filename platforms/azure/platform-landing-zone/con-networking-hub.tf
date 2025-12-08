#==========================================#
# Platform LZ: Connectivity - Network (Hub)
#==========================================#

locals {
  name_part   = "${var.naming["prefix"]}-${var.naming["service"]}-con-hub" # Combine name parts in to single var.
}

# Create Resource Group for hub networking.
resource "azurerm_resource_group" "plz_con_hub_rg" {
  name     = "${local.name_part}-rg"
  location = var.location
  tags     = var.tags
}

#======================================#
# Network: Hub - VNet & Subnet
#======================================#

# Create: Virtual Network (Hub)
resource "azurerm_virtual_network" "plz_con_hub_vnet" {
  name                = "${local.name_part}-vnet"
  location            = azurerm_resource_group.plz_con_hub_rg.location
  resource_group_name = azurerm_resource_group.plz_con_hub_rg.name
  address_space       = [var.hub_vnet_space]
  tags                = var.tags
}

# Create: Virtual Network Subnet (Primary)
resource "azurerm_subnet" "plz_con_hub_subnet" {
  for_each = var.hub_subnets
  name                 = "${local.name_part}-sn1"
  resource_group_name  = azurerm_virtual_network.plz_con_hub_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.plz_con_hub_vnet.name
  address_prefixes     = [var.subnet_space]
  default_outbound_access_enabled = true # Disable for prevent system-assigned, outbound-only public IP.
}

#======================================#
# Network Security Group (NSG)
#======================================#

# NSG rules to be defined in separate files.
resource "azurerm_network_security_group" "plz_con_hub_sn1_nsg" {
  name                = "${local.name_part}-sn1-nsg"
  location            = azurerm_virtual_network.plz_con_hub_vnet.location
  resource_group_name = azurerm_virtual_network.plz_con_hub_vnet.resource_group_name
  tags                = var.tags
}

# Associate NSG with subnet.
resource "azurerm_subnet_network_security_group_association" "plz_con_hub_sn1_nsg_assoc" {
  subnet_id                 = azurerm_subnet.plz_con_hub_sn1.id
  network_security_group_id = azurerm_network_security_group.plz_con_hub_sn1_nsg.id
}

#======================================#
# Network Watcher
#======================================#'

resource "azurerm_network_watcher" "plz_con_hub_nw" {
  name                = "${local.name_part}-nw"
  location            = azurerm_resource_group.plz_con_hub_rg.location
  resource_group_name = azurerm_resource_group.plz_con_hub_rg.name
  tags                = var.tags
}
