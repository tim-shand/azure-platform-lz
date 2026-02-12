# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                   # Map of name related variables (merge with "global.naming")
    workload_code = "idn"      # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Identity" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                              # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Project     = "PlatformLandingZone" # Workload/project name, used to group and identify related resources.
    Environment = "plz"                 # Workload environment: dev, tst, prd, alz, plz. 
    Owner       = "CloudOpsTeam"        # Name of the team that owns the project. 
    CostCenter  = "Platform"            # Useful for grouping resources for billing/financial accountability.
    Deployment  = "plz-identity"        # Workload/project name, used to group and identify related resources.
  }
}

# Entra ID: Set naming format. 
entra_groups_admins_prefix = "GRP_ADM_" # GRP_ADM_NetworkAdmins
entra_groups_users_prefix  = "GRP_USR_" # GRP_ADM_NetworkAdmins

# Entra ID: Groups (Privilaged RBAC)
entra_groups_admins = {
  "NetworkAdmins" = {
    Description = "RBAC - Privilaged Group: Network Administrators"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "SecurityAdmins" = {
    Description = "RBAC - Privilaged Group: Security Administrators"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "PlatformAdmins" = {
    Description = "RBAC - Privilaged Group: Platform Administrators"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "UserAccessAdmins" = {
    Description = "RBAC - Privilaged Group: User Access Administrators"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
}

# Entra ID: Groups (User Teams)
entra_groups_users = {
  "FinanceTeam" = {
    Description = "User Access: Finance Department"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "ManagementTeam" = {
    Description = "User Access: Management Department"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "SalesTeam" = {
    Description = "User Access: Sales Department"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
  "SupportTeam" = {
    Description = "User Access: Helpdesk Department"
    Active      = true # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
  }
}
