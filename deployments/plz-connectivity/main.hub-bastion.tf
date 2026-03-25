#====================================================================================#
# Connectivity: Azure Bastion Host
# Description: 
# - Create public IP for Bastion host.
# - Create Azure Bastion in dedicated subnet from hub VNet.
#====================================================================================#

# Bastion: Bastion Host
resource "azurerm_bastion_host" "hub" {
  count               = var.hub_bastion.enabled ? 1 : 0 # If Bastion enabled, create, else do not.
  name                = "${module.naming_con.full_name}-bas"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku                 = var.hub_bastion.sku # Standard required for 'Native client support'.
  ip_configuration {
    name                 = "ipconfig-hub-bastion"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].ip_address
  }
  copy_paste_enabled     = true                                          # Basic, Standard
  file_copy_enabled      = var.hub_bastion.sku == "Basic" ? false : true # REQUIRES: Standard SKU
  tunneling_enabled      = var.hub_bastion.sku == "Basic" ? false : true # REQUIRES: Standard SKU
  shareable_link_enabled = var.hub_bastion.sku == "Basic" ? false : true # REQUIRES: Standard SKU
  kerberos_enabled       = var.hub_bastion.sku == "Basic" ? false : true # REQUIRES: Standard SKU
  ip_connect_enabled     = var.hub_bastion.sku == "Basic" ? false : true # REQUIRES: Standard SKU
}

# Bastion: Public IP
resource "azurerm_public_ip" "bastion" {
  count               = var.hub_bastion.enabled ? 1 : 0 # If Bastion enabled, create, else do not.
  name                = "${module.naming_con.full_name}-bas-pip"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion: Subnet
resource "azurerm_subnet" "bastion" {
  count                           = var.hub_bastion.enabled ? 1 : 0 # Only create if enabled.
  name                            = "AzureBastionSubnet"            # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = var.hub_bastion.subnet
  default_outbound_access_enabled = true # Required for Bastion services to operate correctly. # Disable to prevent outbound Internet via subnet (force gateway).
}

# Bastion: NSG
resource "azurerm_network_security_group" "bastion" {
  count               = var.hub_bastion.enabled ? 1 : 0 # Only create if enabled.
  name                = "${module.naming_con.full_name}-bas-nsg"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  # Define rules for NSG.

  # Inbound --------------------------------------- #
  security_rule {
    name                       = "Allow-Inbound-InternetToBastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "Internet" # VirtualNetwork, AzureLoadBalancer, Internet.
  }
  security_rule {
    name                       = "Allow-Inbound-GatewayToBastion"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "GatewayManager" # VirtualNetwork, AzureLoadBalancer, Internet.
  }

  # Outbound --------------------------------------- #
  security_rule {
    name                       = "Allow-Outbound-BastionToVMs"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["3389", "22"]
    destination_address_prefix = "VirtualNetwork" # VirtualNetwork, AzureLoadBalancer, Internet.
  }
}
