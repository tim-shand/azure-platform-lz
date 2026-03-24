#====================================================================================#
# Connectivity: Azure Firewall
# Description: 
# - Create public IP for Azure Firewall.
# - Create Azure Firewall in dedicated subnet from hub VNet.
#====================================================================================#

# Firewall: Public IP
resource "azurerm_public_ip" "fw" {
  count               = var.hub_firewall.enabled ? 1 : 0
  name                = "${module.naming_con.full_name}-fwl-pip"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Firewall: Public IP (Management)
resource "azurerm_public_ip" "fw_mgt" {
  count               = var.hub_firewall.enabled ? 1 : 0
  name                = "${module.naming_con.full_name}-fwl-mgt-pip"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Hub: Subnet - Firewall
resource "azurerm_subnet" "fw" {
  count                           = var.hub_firewall.enabled ? 1 : 0 # Only create if enabled.
  name                            = "AzureFirewallSubnet"            # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = var.hub_firewall.subnet
  default_outbound_access_enabled = false # Disable to prevent outbound Internet via subnet.
}

# Hub: Subnet - Firewall Management
resource "azurerm_subnet" "fw_mgt" {
  count                           = var.hub_firewall.enabled ? 1 : 0 # Only create if enabled.
  name                            = "AzureFirewallManagementSubnet"  # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = var.hub_firewall.subnet_mgt
  default_outbound_access_enabled = false # Disable to prevent outbound Internet via subnet.
}

# Firewall
resource "azurerm_firewall" "hub" {
  name                = "${module.naming_con.full_name}-fwl"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku_name            = var.hub_firewall.sku_name
  sku_tier            = var.hub_firewall.sku_tier
  ip_configuration {
    name                 = "ipconfig-hub-firewall"
    subnet_id            = azurerm_subnet.fw[0].id
    public_ip_address_id = azurerm_public_ip.fw[0].id
  }
  management_ip_configuration {
    name                 = "ipconfig-hub-firewall-mgt"
    subnet_id            = azurerm_subnet.fw_mgt[0].id
    public_ip_address_id = azurerm_public_ip.fw_mgt[0].id
  }
}
