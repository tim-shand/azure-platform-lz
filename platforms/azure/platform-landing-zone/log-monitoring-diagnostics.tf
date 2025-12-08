#================================================#
# Platform LZ: Logging - Monitoring & Diagnostics
#================================================#

locals {
  name_part      = "${var.naming["prefix"]}-${var.naming["service"]}-log-mon" # Combine name parts in to single var.
  sa_name_max_length = 19 # Random integer suffix will add 5 chars, so max = 19 for base name.
  sa_name_base       = "${var.naming["prefix"]}${var.naming["service"]}${var.naming["project"]}logsa${random_integer.rndint.result}"
  sa_name_truncated  = length(local.sa_name_base) > local.sa_name_max_length ? substr(local.sa_name_base, 0, local.sa_name_max_length - 5) : local.sa_name_base
}

# Generate a random integer to use for suffix for uniqueness.
resource "random_integer" "rndint" {
  min = 10000
  max = 99999
}

# Create Resource Group.
resource "azurerm_resource_group" "plz_log_mon_rg" {
  name     = "${local.name_part}-rg"
  location = var.location
  tags     = var.tags
}

#======================================#
# Monitoring: Log Analytics
#======================================#

# Storage Account for centralized logs.
resource "azurerm_storage_account" "plz_log_mon_sa" {
  name                     = "${local.sa_name_truncated}"
  resource_group_name      = azurerm_resource_group.plz_log_mon_rg.name
  location                 = azurerm_resource_group.plz_log_mon_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  https_traffic_only_enabled = true
  tags                     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "plz_log-mon_law" {
  name                = "${local.name_part}-law"
  resource_group_name = azurerm_resource_group.plz_log_mon_rg.name
  location            = azurerm_resource_group.plz_log_mon_rg.location
  tags                = var.tags
  sku                 = var.logging_law.sku
  retention_in_days   = var.logging_law.retention_days
}
