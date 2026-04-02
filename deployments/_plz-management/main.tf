#====================================================================================#
# Management: Logging and Monitoring
# Description: 
# - Deploy resources for centralised log collection and monitoring. 
# - Deploy Storage Account for log archiving.    
#====================================================================================#

# GENERAL ------------------------------------------------------------------ #

# Naming: Generate naming convention, pre-determined values and format. 
module "naming" {
  source        = "../../modules/global-resource-naming"
  prefix        = var.global.naming.org_prefix
  workload      = var.global.naming.workload_project
  stack_or_env  = var.stack.naming.workload_code
  ensure_unique = true
}

# Resource Group
resource "azurerm_resource_group" "mgt" {
  name     = module.naming.resource_group
  location = var.global.location.primary
  tags     = local.tags_merged
}

# Key Vault: Stores platform secrets and certificates.
resource "azurerm_key_vault" "mgt" {
  name                       = module.naming.key_vault
  resource_group_name        = azurerm_resource_group.mgt.name
  location                   = azurerm_resource_group.mgt.location
  tags                       = local.tags_merged
  tenant_id                  = data.azuread_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true                                     # Enforce RBAC roles over access policies (legacy).
  purge_protection_enabled   = var.key_vault_soft_purge_protection      # Enable purge protection (defautl: false).
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days # Days to keep soft-deleted.
}


# LOGGING ------------------------------------------------------------------ #

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "mgt" {
  name                = module.naming.log_analytics_workspace
  resource_group_name = azurerm_resource_group.mgt.name
  location            = azurerm_resource_group.mgt.location
  tags                = local.tags_merged
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
}

# Storage Account: Archive logs.
resource "azurerm_storage_account" "mgt" {
  name                            = module.naming.storage_account
  resource_group_name             = azurerm_resource_group.mgt.name
  location                        = azurerm_resource_group.mgt.location
  tags                            = local.tags_merged
  account_tier                    = "Standard"  # Standard, Premium
  account_replication_type        = "LRS"       # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind                    = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, StorageV2
  https_traffic_only_enabled      = true        # Enforce secure file transfer. 
  allow_nested_items_to_be_public = false       # Prevent anonymous/public access to Storage Accounts. 
  shared_access_key_enabled       = false       # SECURITY: Disable Shared Key Access in favour of Entra ID authorization.
}

# Data Collection Endpoint: Required for Azure Monitor Agent-based data collection (modern, agentless-friendly).
resource "azurerm_monitor_data_collection_endpoint" "mgt" {
  name                = module.naming.data_collection_endpoint
  resource_group_name = azurerm_resource_group.mgt.name
  location            = azurerm_resource_group.mgt.location
  tags                = local.tags_merged
}

# Data Collection Rule: Defines what data is collected and where it is sent.
resource "azurerm_monitor_data_collection_rule" "mgt" {
  name                        = module.naming.data_collection_rule
  resource_group_name         = azurerm_resource_group.mgt.name
  location                    = azurerm_resource_group.mgt.location
  tags                        = local.tags_merged
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.mgt.id
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.mgt.id
      name                  = "law-destination"
    }
  }
  data_flow {
    streams      = ["Microsoft-Event", "Microsoft-Syslog", "Microsoft-Perf"]
    destinations = ["law-destination"]
  }
  data_sources {
    performance_counter {
      name                          = "perf-metrics"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\LogicalDisk(_Total)\\Disk Read Bytes/sec",
        "\\LogicalDisk(_Total)\\Disk Write Bytes/sec",
        "\\Network Interface(*)\\Bytes Total/sec",
      ]
    }
    windows_event_log {
      name    = "windows-events"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Security!*[System[(band(Keywords,4503599627370496))]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]",
      ]
    }
    syslog {
      name    = "linux-syslog"
      streams = ["Microsoft-Syslog"]
      facility_names = [
        "auth", "authpriv", "daemon",
        "kern", "syslog", "user",
      ]
      log_levels = ["Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }
}

# DEFENDER FOR CLOUD ------------------------------------------------------------------ #
# Microsoft Cloud Security Benchmark (MCSB) is free.
# Individual Defender plans (VMs, Storage, SQL) are paid and controlled by flag.

# Security Center: Send to Log Insights Workspace.
resource "azurerm_security_center_workspace" "mgt" {
  scope        = "/subscriptions/00000000-0000-0000-0000-000000000000"
  workspace_id = azurerm_log_analytics_workspace.mgt.id
}

# Defender for Cloud (CSPM): Virtual Machines
resource "azurerm_security_center_subscription_pricing" "mdfc_vms" {
  count         = var.mdfc_enable_defender_cspm ? 1 : 0
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

# Defender for Cloud (CSPM): Storage Accounts
resource "azurerm_security_center_subscription_pricing" "mdfc_storage" {
  count         = var.mdfc_enable_defender_cspm ? 1 : 0
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

# Defender for Cloud (CSPM): Key Vaults
resource "azurerm_security_center_subscription_pricing" "mdfc_keyvault" {
  count         = var.mdfc_enable_defender_cspm ? 1 : 0
  tier          = "Standard"
  resource_type = "KeyVaults"
}

# Defender for Cloud (CSPM): App Services
resource "azurerm_security_center_subscription_pricing" "mdfc_appservices" {
  count         = var.mdfc_enable_defender_cspm ? 1 : 0
  tier          = "Standard"
  resource_type = "AppServices"
}

