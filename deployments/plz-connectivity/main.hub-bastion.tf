#====================================================================================#
# Connectivity: Azure Bastion Host
# Description: 
# - Create public IP for Bastion host.
# - Create Azure Bastion in dedicated subnet from hub VNet.
#====================================================================================#

# NOTICE: Note on NSGs for Bastion.
# AzureBastionSubnet must have an NSG applied, and that NSG must have specific rules.
# Microsoft mandates the exact inbound and outbound rules for Bastion to function.
# Without them Bastion will deploy but connections will fail.

# NETWORKING ----------------------------------------------------------- #

# Bastion: Public IP
resource "azurerm_public_ip" "bastion" {
  count               = var.hub_bastion.enabled ? 1 : 0 # If Bastion enabled, create, else do not.
  name                = "${module.naming_con.public_ip}-bas"
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
  address_prefixes                = [var.hub_bastion.subnets[0]]
  default_outbound_access_enabled = false # Disable to prevent outbound Internet via subnet.
}

# BASTION ----------------------------------------------------------- #

# Bastion: Bastion Host
resource "azurerm_bastion_host" "hub" {
  count               = var.hub_bastion.enabled ? 1 : 0 # If Bastion enabled, create, else do not.
  name                = module.naming_con.bastion
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku                 = var.hub_bastion.sku_tier
  ip_configuration {
    name                 = "ipconfig-hub-bastion"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].ip_address
  }
  copy_paste_enabled = local.bastion_features.copy_paste_enabled
  file_copy_enabled = local.bastion_features.file_copy_enabled
  tunneling_enabled = local.bastion_features.tunneling_enabled
  shareable_link_enabled = local.bastion_features.shareable_link_enabled
  kerberos_enabled = local.bastion_features.kerberos_enabled
  ip_connect_enabled = local.bastion_features.ip_connect_enabled
  session_recording_enabled = local.bastion_features.session_recording_enabled
  # copy_paste_enabled        = var.hub_bastion.features.copy_paste_enabled
  # # NOTE: The below options require 'Standard' SKU.
  # file_copy_enabled         = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.file_copy_enabled
  # tunneling_enabled         = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.tunneling_enabled
  # shareable_link_enabled    = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.shareable_link_enabled
  # kerberos_enabled          = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.kerberos_enabled
  # ip_connect_enabled        = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.ip_connect_enabled
  # session_recording_enabled = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.session_recording_enabled
}

# NETWORK SECURITY GROUP: Bastion ------------------------------------------------------------ #

# Bastion: NSG Association (link to subnet).
resource "azurerm_subnet_network_security_group_association" "bastion" {
  count                     = var.hub_bastion.enabled ? 1 : 0
  subnet_id                 = azurerm_subnet.bastion[0].id
  network_security_group_id = azurerm_network_security_group.bastion[0].id
}

# Bastion: NSG
resource "azurerm_network_security_group" "bastion" {
  count               = var.hub_bastion.enabled ? 1 : 0 # Only create if enabled.
  name                = "${module.naming_con.nsg}-bas"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  # Define rules for NSG.

  # Inbound ----------------------------------------------------------------------- #

  # Allow HTTPS from internet — required for portal and native client access
  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow control plane traffic from GatewayManager
  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  # Allow Azure Load Balancer health probes
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Allow Bastion host communication — required for multi-host deployments
  security_rule {
    name                       = "AllowBastionHostCommunicationInbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Deny all other inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound ----------------------------------------------------------------------- #

  # Allow SSH and RDP to target VMs in VNet
  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow Azure platform communication
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  # Allow Bastion host communication
  security_rule {
    name                       = "AllowBastionHostCommunicationOutbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow session information to be stored — required for Bastion diagnostics
  security_rule {
    name                       = "AllowGetSessionInformationOutbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  # Deny all other outbound
  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
