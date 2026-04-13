#====================================================================================#
# Management: Logging Resources
# Description: 
# - Deploy Log Analytics Workspace and Storage Account. 
# - Deploy Data Collection Endpoint and Rule.
#====================================================================================#

# LOGGING ------------------------------------------------------------------ #

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "mgt" {
  name                = module.naming.log_analytics_workspace
  resource_group_name = azurerm_resource_group.mgt.name
  location            = azurerm_resource_group.mgt.location
  tags                = local.tags_merged
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.log_daily_quota_gb
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

resource "azurerm_storage_management_policy" "mgt" {
  storage_account_id = azurerm_storage_account.mgt.id
  rule {
    name    = "archive-and-expire-logs"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = var.log_archive_retention_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
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
  name                        = "${module.naming.data_collection_rule}-vms"
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
