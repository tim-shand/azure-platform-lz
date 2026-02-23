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
policy_diagnostics_effect = "DeployIfNotExists" # DeployIfNotExists, AuditIfNotExists, Disabled
policy_activity_effect    = "DeployIfNotExists" # DeployIfNotExists, Disabled

# Define Action Groups and email recipients. 
action_groups = {
  "p1" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
  "p2" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
  "p3" = {
    email_address = [
      "alerts@tshand.com"
    ]
  }
}

# Alert Priorities: Map to priorities for Action Group assignments. 
activity_log_alerts = {
  Administrative = {
    severity_level = "p3"    # Assign Action Group (p1, p2, p3). 
    level          = "Error" # Only required for Administrative category. 
  }
  Policy = {
    severity_level = "p3" # Assign Action Group (p1, p2, p3).
  }
  Security = {
    severity_level = "p2" # Assign Action Group (p1, p2, p3).
  }
  ServiceHealth = {
    severity_level = "p1" # Assign Action Group (p1, p2, p3).
  }
  ResourceHealth = {
    severity_level = "p1" # Assign Action Group (p1, p2, p3).
  }
}
