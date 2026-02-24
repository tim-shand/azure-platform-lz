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

# Log Analytics
law_retenion_days = 30 # Days to retain logs in LOg Analytics Workspace. 

# Policy, Diagnostics & Logging
policy_diagnostic_settings_effect = "AuditIfNotExists" # DeployIfNotExists, AuditIfNotExists, Disabled
policy_activity_logs_effect       = "AuditIfNotExists" # DeployIfNotExists, AuditIfNotExists, Disabled

# Define Action Groups and email recipients. 
action_groups = {
  "platform" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
  "security" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
  "support" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
}

# Activity Alerts: Map of properties.  
activity_log_alerts = {
  Administrative = {
    action_group = "platform"              # Assign Action Group from "action_groups". 
    enabled      = true                    # [True/False]: Enable this activity log alert. 
    level        = "Warning"               # Define the severity levels ("Warning", "Error", "Critical"). 
    statuses     = ["Succeeded", "Failed"] # Define the status events ("Started", Failed", "Succeeded"). []
  }
  Policy = {
    action_group = "platform" # Assign Action Group from "action_groups". 
    enabled      = true       # [True/False]: Enable this activity log alert. 
    level        = "Warning"  # Define the severity levels ("Warning", "Error", "Critical"). 
    statuses     = ["Failed"] # Define the status events ("Started", Failed", "Succeeded"). []
  }
  Security = {
    action_group = "security"              # Assign Action Group from "action_groups". 
    enabled      = true                    # [True/False]: Enable this activity log alert. 
    level        = "Warning"               # Define the severity levels ("Warning", "Error", "Critical"). 
    statuses     = ["Succeeded", "Failed"] # Define the status events ("Started", Failed", "Succeeded"). []
  }
  ServiceHealth = {
    action_group = "support"                                                 # Assign Action Group from "action_groups". 
    enabled      = true                                                      # [True/False]: Enable this activity log alert. 
    events       = ["Incident", "Maintenance", "ActionRequired", "Security"] # "Incident", "Maintenance", "Informational", "ActionRequired", "Security"
    locations    = ["Global", "New Zealand North", "Australia East"]
  }
  ResourceHealth = {
    action_group = "support"                              # Assign Action Group from "action_groups". 
    enabled      = true                                   # [True/False]: Enable this activity log alert. 
    current      = ["Degraded", "Unavailable", "Unknown"] # Define status: Available, Degraded, Unavailable and Unknown
  }
}

# Diagnostic Logs: Entra ID
entraid_log_types = {
  "AuditLogs"                           = true  # [True/False]: Enable or disable logging for category. 
  "SignInLogs"                          = true  # [True/False]: Enable or disable logging for category. 
  "NonInteractiveUserSignInLogs"        = true  # [True/False]: Enable or disable logging for category. 
  "ServicePrincipalSignInLogs"          = true  # [True/False]: Enable or disable logging for category. 
  "ManagedIdentitySignInLogs"           = true  # [True/False]: Enable or disable logging for category. 
  "ProvisioningLogs"                    = true  # [True/False]: Enable or disable logging for category. 
  "ADFSSignInLogs"                      = true  # [True/False]: Enable or disable logging for category. 
  "RiskyUsers"                          = true  # [True/False]: Enable or disable logging for category. 
  "UserRiskEvents"                      = true  # [True/False]: Enable or disable logging for category. 
  "NetworkAccessTrafficLogs"            = false # [True/False]: Enable or disable logging for category. 
  "RiskyServicePrincipals"              = true  # [True/False]: Enable or disable logging for category. 
  "ServicePrincipalRiskEvents"          = true  # [True/False]: Enable or disable logging for category. 
  "EnrichedOffice365AuditLogs"          = false # [True/False]: Enable or disable logging for category. 
  "MicrosoftGraphActivityLogs"          = true  # [True/False]: Enable or disable logging for category. 
  "RemoteNetworkHealthLogs"             = false # [True/False]: Enable or disable logging for category. 
  "NetworkAccessAlerts"                 = false # [True/False]: Enable or disable logging for category. 
  "NetworkAccessConnectionEvents"       = false # [True/False]: Enable or disable logging for category. 
  "MicrosoftServicePrincipalSignInLogs" = false # [True/False]: Enable or disable logging for category. 
  "AzureADGraphActivityLogs"            = true  # [True/False]: Enable or disable logging for category. 
  "NetworkAccessGenerativeAIInsights"   = false # [True/False]: Enable or disable logging for category. 
  "GraphNotificationsActivityLogs"      = false # [True/False]: Enable or disable logging for category. 
}
