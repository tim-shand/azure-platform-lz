#====================================================================================#
# Connectivity: Network Watcher
# Description: 
# - Create Network Watcher resource for traffic analysis.
# - Send traffic logs to management stack Log Analytics Workspace via flow log.
#====================================================================================#

# Network Watcher: Main
resource "azurerm_network_watcher" "hub" {
  name                = "${module.naming_con.full_name}-nww"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
}

# Network Watcher: Flow Log
resource "azurerm_network_watcher_flow_log" "hub" {
  name                 = "${module.naming_con.full_name}-nfl"
  network_watcher_name = azurerm_network_watcher.hub.name
  resource_group_name  = azurerm_resource_group.con.name
  location             = azurerm_resource_group.con.location
  tags                 = local.tags_merged
  enabled              = true
  target_resource_id   = azurerm_virtual_network.hub.id                     # ID of the hub VNet. 
  storage_account_id   = data.azurerm_app_configuration_key.log_sa_id.value # Storage Account in Management stack (required). 
  retention_policy {
    enabled = true
    days    = 30
  }
  traffic_analytics {
    enabled               = true
    workspace_id          = data.azurerm_log_analytics_workspace.log_law.workspace_id
    workspace_region      = data.azurerm_log_analytics_workspace.log_law.location
    workspace_resource_id = data.azurerm_log_analytics_workspace.log_law.id
    interval_in_minutes   = 10
  }
}
