#====================================================================================#
# Connectivity: Hub VNet
# Description: 
# - Create VNet for centralized hub connectivity.
# - Deploy Network Watcher and VNet flow logs to Log Analytics.
#====================================================================================#

# VNet: Hub
resource "azurerm_virtual_network" "hub" {
  name                = "${module.naming_con.virtual_network}"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  address_space       = [var.ip_address_space.hub]
}

# SUBNETS --------------------------------------------------- #

# Shared Subnet
resource "azurerm_subnet" "shared" {
  name                            = var.hub_shared.name
  resource_group_name             = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = [var.hub_shared.subnets[0]]
  default_outbound_access_enabled = false # Disable to prevent outbound Internet via subnet.
}

# NETWORK WATCHER --------------------------------------------------- #

# Network Watcher: Hub
resource "azurerm_network_watcher" "hub" {
  name                = "${module.naming_con.network_watcher}"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
}

# Network Watcher: Flow Log
resource "azurerm_network_watcher_flow_log" "hub" {
  name                 = "${module.naming_con.virtual_network}-flowlog"
  network_watcher_name = azurerm_network_watcher.hub.name
  resource_group_name  = azurerm_network_watcher.hub.resource_group_name
  location             = azurerm_network_watcher.hub.location
  tags                 = local.tags_merged
  enabled              = true
  target_resource_id   = azurerm_virtual_network.hub.id     # ID of the hub VNet. 
  storage_account_id   = local.mgt_storage_account.id       # Storage Account in Management stack (required). 
  retention_policy {
    enabled = true
    days    = 30
  }
  traffic_analytics {
    enabled               = true
    workspace_id          = local.mgt_law_workspace.workspace_id
    workspace_region      = local.mgt_law_workspace.location
    workspace_resource_id = local.mgt_law_workspace.id
    interval_in_minutes   = 60
  }
}
