#====================================================================================#
# Connectivity: Azure Firewall
# Description: 
# - Create public IP for Azure Firewall.
# - Create Azure Firewall in dedicated subnet from hub VNet.
#====================================================================================#

# NOTICE: Note on use of NSGs:
# AzureFirewallSubnet and AzureFirewallManagementSubnet cannot have NSGs applied. Azure explicitly blocks this.
# The Firewall manages its own traffic filtering via Firewall Policy and does not support NSG association on its subnets.
# Attempting to apply one will result in a deployment error.

# PUBLIC IPS --------------------------------------------------- #

# Firewall: Public IP (External)
resource "azurerm_public_ip" "fw" {
  count               = var.hub_firewall.enabled ? 1 : 0
  name                = "${module.naming_con.public_ip}-fwl"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Firewall: Public IP (Management)
resource "azurerm_public_ip" "fw_mgt" {
  count               = var.hub_firewall.enabled ? 1 : 0
  name                = "${module.naming_con.public_ip}-fwl-mgt"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# SUBNETS --------------------------------------------------- #

# Firewall: Subnet
resource "azurerm_subnet" "fw" {
  count                           = var.hub_firewall.enabled ? 1 : 0 # Only create if enabled.
  name                            = "AzureFirewallSubnet"            # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = [var.hub_firewall.subnets[0]]
  default_outbound_access_enabled = false # Disable to prevent outbound Internet via subnet.
}

# Firewall: Subnet (Management)
resource "azurerm_subnet" "fw_mgt" {
  count                           = var.hub_firewall.enabled ? 1 : 0 # Only create if enabled.
  name                            = "AzureFirewallManagementSubnet"  # Mandatory naming for this type of subnet.
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = [var.hub_firewall.subnets[1]]
  default_outbound_access_enabled = false # Disable to prevent outbound Internet via subnet.
}

# AZURE FIREWALL ------------------------------------------------------- #

# Firewall: Policy
resource "azurerm_firewall_policy" "hub" {
  count               = var.hub_firewall.enabled ? 1 : 0 # Only create if firewall is enabled.
  name                = module.naming_con.azure_firewall_policy
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  sku                 = var.hub_firewall.policy_sku
  tags                = local.tags_merged
  dns {
    proxy_enabled = var.hub_firewall.policy_sku == "Basic" ? false : true # Required to use FQDNs in network rules.
    servers       = []          # Empty, use Azure default DNS.
  }
}

# Firewall
resource "azurerm_firewall" "hub" {
  count               = var.hub_firewall.enabled ? 1 : 0 # Only create if firewall is enabled.
  name                = module.naming_con.azure_firewall
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku_name            = var.hub_firewall.sku_name
  sku_tier            = var.hub_firewall.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.hub[0].id # Assign firewall policy above.
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
