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

# Key Vault: Stores platform secrets and certificates (for future usage).
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
  for_each     = local.active_subscriptions # Enable for all active subscriptions. 
  scope        = each.value.id              # Assign to each subscription.
  workspace_id = azurerm_log_analytics_workspace.mgt.id
}

# Defender for Cloud (CSPM): Virtual Machines
resource "azurerm_security_center_subscription_pricing" "cspm" {
  for_each      = toset(local.mdfc_cspm_resources_enabled) # Only create if CSPM is enabled, and each resource is enabled.
  tier          = "Standard"
  resource_type = each.value
}

# ACTION GROUPS ------------------------------------------------------------------ #
# Notification target for all platform alerts. Email receivers are free.
resource "azurerm_monitor_action_group" "platform" {
  name                = module.naming.action_group
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  short_name          = "alerts-plz"
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${index(var.alert_email_addresses, email_receiver.value)}"
      email_address = email_receiver.value
    }
  }
}

# ALERTS ------------------------------------------------------------------------- #

# Resource Health Alerts: Monitor individual resource availability.
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  name                = "${module.naming.activity_log_alert}-hth-res"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  description         = "Fires when any resource in the management resource group becomes unavailable."
  scopes              = [for v in local.active_subscriptions : v.id] # Enable for all active subscriptions.  
  enabled             = var.enable_resource_health_alerts
  criteria {
    category = "ResourceHealth"
    resource_health {
      current  = ["Unavailable", "Degraded"]
      previous = ["Available", "Unknown"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

# Service Health Alerts: Covers Azure-side incidents, planned maintenance, health advisories, and security advisories.
resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "${module.naming.activity_log_alert}-hth-srv"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = [for v in local.active_subscriptions : v.id] # Enable for all active subscriptions. 
  description         = "Fires when Azure reports an active service incident affecting this subscription."
  enabled             = var.enable_service_health_alerts
  criteria {
    category = "ServiceHealth"
    service_health {
      locations = local.locations_all # Flattened list.
      events    = ["Incident", "Maintenance", "Security"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

# Administrative Alerts: Delete Attempts.
resource "azurerm_monitor_activity_log_alert" "delete_attempt_resources" {
  name                = "${module.naming.activity_log_alert}-del-res"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global"
  tags                = local.tags_merged
  scopes              = [for sub in local.active_subscriptions : sub.id]
  #scopes      = toset(data.terraform_remote_state.bootstrap.outputs.management_group_core.id) # Remote state data call.
  description = "Fires when specified resource types are attempted to be deleted (Succeeded or Failed)."
  enabled     = var.enable_administrative_alerts
  criteria {
    category       = "Administrative"
    operation_name = "*/delete"
    statuses       = ["Succeeded", "Failed"]
    resource_id    = local.alert_deletion_resource_id
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}
