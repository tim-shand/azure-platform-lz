# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                     # Map of name related variables (merge with "global.naming")
    workload_code = "mgt"        # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Management" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                        # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Owner      = "CloudOpsTeam"   # Name of the team that owns the project. 
    CostCenter = "Platform"       # Useful for grouping resources for billing/financial accountability.
    Deployment = "plz-management" # Workload/project name, used to group and identify related resources.
  }
}

# LOG ANALYTICS ---------------------------------------------------- #

log_retention_days = 30 # Free tier: first 5 GB/day ingestion free, 30-day retention free.
log_daily_quota_gb = 1  # Daily quota cap is set to prevent unexpected cost spikes.

# KEY VAULT -------------------------------------------------------- #

key_vault_soft_delete_retention_days = 30
key_vault_soft_purge_protection      = false
log_analytics_sku                    = "PerGB2018"

# ALERTING -------------------------------------------------------- #

alert_email_addresses          = ["alerts@tshand.com"]
enable_alerts                  = true # Master switch for all alerting.
enabled_resource_health_alerts = true
enabled_service_health_alerts  = true

# DEFENDER FOR CLOUD ----------------------------------------------- #

mdfc_enable_defender_cspm = false # Enable/disable the paid tier for MDfC CSPM.
mdfc_cspm_resources = {           # Will only be enabled if `mdfc_enable_defender_cspm` = true
  AI                            = "true"
  Api                           = "true"
  AppServices                   = "true"
  ContainerRegistry             = "true"
  KeyVaults                     = "true"
  KubernetesService             = "true"
  SqlServers                    = "true"
  SqlServerVirtualMachines      = "true"
  StorageAccounts               = "true"
  VirtualMachines               = "true"
  Arm                           = "false"
  Dns                           = "false"
  OpenSourceRelationalDatabases = "true"
  Containers                    = "true"
  CosmosDbs                     = "false"
  CloudPosture                  = "true"
}

