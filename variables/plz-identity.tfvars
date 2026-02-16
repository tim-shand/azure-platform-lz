# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                   # Map of name related variables (merge with "global.naming")
    workload_code = "idn"      # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Identity" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                      # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Owner      = "CloudOpsTeam" # Name of the team that owns the project. 
    CostCenter = "Platform"     # Useful for grouping resources for billing/financial accountability.
    Deployment = "plz-identity" # Workload/project name, used to group and identify related resources.
  }
}

# Entra ID: Set naming format. 
entra_groups_admins_prefix = "GRP_ADM_" # GRP_ADM_NetworkAdmins
entra_groups_users_prefix  = "GRP_USR_" # GRP_ADM_NetworkAdmins

# Entra ID: Groups (Privilaged RBAC)
entra_groups_admins = {
  "NetworkAdmins" = {
    description       = "RBAC - Privilaged Group: Network Administrators"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
  "SecurityAdmins" = {
    description       = "RBAC - Privilaged Group: Security Administrators"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
  "PlatformAdmins" = {
    description       = "RBAC - Privilaged Group: Platform Administrators"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
  "UserAccessAdmins" = {
    description       = "RBAC - Privilaged Group: User Access Administrators"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
}

# Entra ID: Groups (User Teams)
entra_groups_users = {
  "FinanceTeam" = {
    description       = "User Access: Finance Department"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
  "ManagementTeam" = {
    description       = "User Access: Management Department"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
  "SalesTeam" = {
    description       = "User Access: Sales Department"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
  "SupportTeam" = {
    description       = "User Access: Helpdesk Department"
    active            = true      # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "TJS0001" # Use dummy employee ID as this is public repo. 
  }
}
