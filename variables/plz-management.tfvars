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

# Diagnostics & Logging
policy_diagnostics_effect = "DeployIfNotExists" # AuditIfNotExists, DeployIfNotExists, Disabled
policy_activity_effect    = "DeployIfNotExists" # DeployIfNotExists, Disabled

# Define Action Groups and recipients. 
action_groups = {
  "P1" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
  "P2" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
  "P3" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
}

# Alert Priorities: Map to priorities for Action Group assignments. 
activity_log_alerts = {
  Administrative = "P3" # Assign Action Group (P1, P2, P3). 
  Policy         = "P3" # Assign Action Group (P1, P2, P3). 
  Security       = "P2" # Assign Action Group (P1, P2, P3). 
  ServiceHealth  = "P1" # Assign Action Group (P1, P2, P3). 
  ResourceHealth = "P1" # Assign Action Group (P1, P2, P3). 
}
