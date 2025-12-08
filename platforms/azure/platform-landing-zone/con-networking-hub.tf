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
# Network: Hub - VNet & Subnets
#======================================#

# VNet (Hub)
resource "azurerm_virtual_network" "plz_con_hub_vnet" {
  name                = "${local.name_part}-vnet"
  location            = azurerm_resource_group.plz_con_hub_rg.location
  resource_group_name = azurerm_resource_group.plz_con_hub_rg.name
  address_space       = [var.hub_vnet_space]
  tags                = var.tags
}

# VNet (Hub): Subnets
resource "azurerm_subnet" "plz_con_hub_subnet" {
  for_each             = var.hub_subnets # Loop through map of objects, defining the subnets.
  name                 = "${local.name_part}-${each.value.name}-snet"
  resource_group_name  = azurerm_virtual_network.plz_con_hub_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.plz_con_hub_vnet.name
  address_prefixes     = [each.value.address] # Required to be presented as a list. 
  default_outbound_access_enabled = [each.value.default_outbound_access] # Disable to prevent system-assigned outbound-only public IP.
}

# VNet (Hub): Network Security Groups (NSG). NSG rules to be defined in separate files or TFVARS.
resource "azurerm_network_security_group" "plz_con_hub_subnet_nsg" {
  for_each = var.hub_subnets # Create a separate NSG for each subnet in variable.
  name                = "${local.name_part}-${each.value.name}-nsg"
  location            = azurerm_virtual_network.plz_con_hub_vnet.location
  resource_group_name = azurerm_virtual_network.plz_con_hub_vnet.resource_group_name
  tags                = var.tags
}

# VNet (Hub): Associate NSGs with subnets.
resource "azurerm_subnet_network_security_group_association" "plz_con_hub_snet_nsg_assoc" {
  for_each = var.hub_subnets # Associate each subnet with NSG. 
  subnet_id                 = azurerm_subnet.plz_con_hub_subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.plz_con_hub_subnet_nsg[each.key].id
}

#======================================#
# Network: Network Watcher (Logging)
#======================================#

# VNet (Hub): Network Watcher
resource "azurerm_network_watcher" "plz_con_hub_nw" {
  name                = "${local.name_part}-nw"
  location            = azurerm_resource_group.plz_con_hub_rg.location
  resource_group_name = azurerm_resource_group.plz_con_hub_rg.name
  tags                = var.tags
}

# VNet (Hub): Network Watcher - Flow Logs
resource "azurerm_network_watcher_flow_log" "plz_con_hub_logs" {
  name                 = "${azurerm_virtual_network.plz_con_hub_vnet.name}-log"
  location = var.location
  resource_group_name  = azurerm_resource_group.plz_con_hub_rg.name
  tags = var.tags
  network_watcher_name = azurerm_network_watcher.plz_con_hub_nw.name # Network Watcher created above.
  storage_account_id         = azurerm_storage_account.plz_log_mon_sa.id # Storage Account held in Logging RG.
  target_resource_id         = azurerm_virtual_network.plz_con_hub_vnet.id # Target the VNet. 
  enabled                    = true # Flow Log: Enabled
  version                    = 2
  retention_policy {
    enabled = true # Retention Policy: Enabled
    days    = 30
  }
  traffic_analytics {
    enabled               = true # Traffic Analytics: Enabled
    workspace_id          = azurerm_log_analytics_workspace.plz_log-mon_law.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.plz_log-mon_law.location
    workspace_resource_id = azurerm_log_analytics_workspace.plz_log-mon_law.id
    interval_in_minutes   = 10
  }
}

# VNet (Hub): Network Watcher - Flow Logs
resource "azurerm_monitor_diagnostic_setting" "plz_con_hub_diag" {
  name               = "${azurerm_virtual_network.plz_con_hub_vnet.name}-diag"
  target_resource_id = azurerm_virtual_network.plz_con_hub_vnet.id # VNet ID. 
  log_analytics_workspace_id = azurerm_log_analytics_workspace.plz_log-mon_law.workspace_id # Send to LAW workspace. 

  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}