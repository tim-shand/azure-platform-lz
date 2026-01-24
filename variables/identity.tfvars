# General 
naming = {
  stack_name = "Identity" # Full stack name. Used with tag assignment and naming. 
  stack_code = "idn"      # Short code used for resource naming. 
}
tags = {
  Deployment = "Identity" # Deployment specific tags (merged with global tags). 
}

# Entra ID: Groups
entra_groups = {
  "grp-std-management" = {
    display_name = "Grp-STD-Management"
    description  = "Group: Standard Role - Management Team"
  }
  "grp-std-finance-payroll" = {
    display_name = "Grp-STD-Finance-Payroll"
    description  = "Group: Standard Role - Finance/Payroll Team"
  }
  "grp-std-finance-accounts" = {
    display_name = "Grp-STD-Finance-Accounts"
    description  = "Group: Standard Role - Finance/Accounts Team"
  }
  "grp-std-support-l1" = {
    display_name = "Grp-STD-Support-L1"
    description  = "Group: Standard Role - Support (Level 1)"
  }
  "grp-std-support-l2" = {
    display_name = "Grp-STD-Support-L2"
    description  = "Group: Standard Role - Support (Level 2)"
  }
  "grp-std-support-l3" = {
    display_name = "Grp-ADM-Support-L3"
    description  = "Group: Privilaged Role - Support (Level 3)"
  }
  "grp-adm-platform" = {
    display_name = "Grp-ADM-Platform"
    description  = "Group: Privilaged Role - Platform Team"
  }
  "grp-adm-security" = {
    display_name = "Grp-ADM-Security"
    description  = "Group: Privilaged Role - Security Team"
  }
  "grp-adm-network" = {
    display_name = "Grp-ADM-Network"
    description  = "Group: Privilaged Role - Network Team"
  }
}

# # RBAC: Assign RBAC roles to default groups for Management Groups. 
# group_role_assignments = {
#   "grp-adm-platform" = {
#     role_name    = "Owner"
#     scope_type   = "management_group"
#     scope_target = "platform"
#   }
#   "grp-adm-security" = {
#     role_name    = "Security Administrator"
#     scope_type   = "management_group"
#     scope_target = "platform"
#   }
#   "grp-adm-network" = {
#     role_name    = "Network Contributor"
#     scope_type   = "management_group"
#     scope_target = "platform"
#   }
#   "grp-std-support-l1" = {
#     role_name    = "Reader"
#     scope_type   = "management_group"
#     scope_target = "workloads"
#   }
#   "grp-adm-support-l2" = {
#     role_name    = "Reader"
#     scope_type   = "management_group"
#     scope_target = "workloads"
#   }
#   "grp-adm-support-l2" = {
#     role_name    = "Reader"
#     scope_type   = "management_group"
#     scope_target = "platform"
#   }
#   "grp-adm-support-l3" = {
#     role_name    = "Reader"
#     scope_type   = "management_group"
#     scope_target = "core"
#   }
# }

# Key Vault: Store Default Credentials
kv_soft_delete_retention_days = 7
kv_purge_protection_enabled   = false
