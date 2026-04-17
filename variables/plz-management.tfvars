# GENERAL ---------------------------------------------------- #

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

# Enable/disable resource deployment.
enable_resource_deployment = {
  alerting = true
  defender_for_cloud = true
  key_vault = true
  logging = true
  entra_id_privilaged_groups = true
}

# LOGGING ---------------------------------------------------- #

log_retention_days         = 30  # Free tier: first 5 GB/day ingestion free, 30-day retention free.
log_daily_quota_gb         = 1   # Daily quota cap is set to prevent unexpected cost spikes.
log_archive_retention_days = 120 # Number of days until deletion from archive.
log_archiving_storage_account = {
  enabled = true
  tables = {
    "Alert" = true
    "Operation" = true
    "Metrics" = true
    "SecurityEvent" = true
    "Syslog" = true
    "Perf" = true
    "Heartbeat" = true
    "AzureDiagnostics" = true
  }
}

# KEY VAULT -------------------------------------------------------- #

key_vault_soft_delete_retention_days = 30
key_vault_soft_purge_protection      = false
log_analytics_sku                    = "PerGB2018"

# ACTION GROUPS -------------------------------------------------------- #

action_groups = {
  "platform" = {
    name           = "Platform Team"
    email          = ["alerts@tshand.com"]
    enabled = true
  }
  "security" = {
    name           = "Security Team"
    email          = ["alerts@tshand.com"]
    enabled = true
  }
}

# ALERTING -------------------------------------------------------- #

# Enabled/disable alerts by category.
enabled_alerts = {
  resource_health_alerts = true
  service_health_alerts  = true
  administrative_alerts  = true
}

# Alert controls for MDFC.
mdfc_alerts = {
  alert_notifications = true # Send security alerts notifications to the security contact.
  alerts_to_admins    = false # Send security alerts notifications to subscription admins.
}

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

# ENTRA ID ----------------------------------------------- #

# Entra ID: Groups (Privilaged RBAC) 
entra_groups_prefix = "GRP_ADM_" # GRP_ADM_NetworkAdmins
entra_groups_privilaged = {
  "NetworkAdmins" = {
    description       = "RBAC - Privilaged Group: Network Administrators"
    active            = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "SecurityAdmins" = {
    description       = "RBAC - Privilaged Group: Security Administrators"
    active            = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "PlatformAdmins" = {
    description       = "RBAC - Privilaged Group: Platform Administrators"
    active            = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "UserAccessAdmins" = {
    description       = "RBAC - Privilaged Group: User Access Administrators"
    active            = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
}

# Diagnostic Logs: Entra ID - [True/False]: Enable or disable logging for category.
entraid_log_types = {
  "AuditLogs"                           = true
  "SignInLogs"                          = true 
  "NonInteractiveUserSignInLogs"        = true 
  "ServicePrincipalSignInLogs"          = true 
  "ManagedIdentitySignInLogs"           = true 
  "ProvisioningLogs"                    = true 
  "ADFSSignInLogs"                      = true 
  "RiskyUsers"                          = true
  "UserRiskEvents"                      = true 
  "NetworkAccessTrafficLogs"            = false
  "RiskyServicePrincipals"              = true 
  "ServicePrincipalRiskEvents"          = true 
  "EnrichedOffice365AuditLogs"          = false 
  "MicrosoftGraphActivityLogs"          = true 
  "RemoteNetworkHealthLogs"             = false
  "NetworkAccessAlerts"                 = false 
  "NetworkAccessConnectionEvents"       = false 
  "MicrosoftServicePrincipalSignInLogs" = false
  "AzureADGraphActivityLogs"            = true 
  "NetworkAccessGenerativeAIInsights"   = false 
  "GraphNotificationsActivityLogs"      = false 
}
