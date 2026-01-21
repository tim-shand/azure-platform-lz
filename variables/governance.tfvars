# General
naming = {
  stack_name = "Governance" # Full stack name. Used with tag assignment and naming. 
  stack_code = "gov"        # Short code used for resource naming. 
}

# Governance: Management Groups
management_group_root = "Core" # Top level Management Group name.

# Subscription Prefixes: First 3 segments of subscription IDs (example: "1234-1234-1234"). 
subscription_prefixes = { # Used to assign subscriptions to management groups.
  platform       = ["56effccd-9f6c-4b5e", "8cf80f38-0042-413a"]
  workloads_prd  = ["9173fb12-e761-49ab"]
  workloads_dev  = []
  sandbox        = ["66f229bc-adb1-4b24"]
  decommissioned = []
}

# Governance: Policy Configuration
policy_log_analytics_id            = ""                  # ID of the shared services Log Analytics Workspace. 
policy_initiatives_builtin         = ["New Zealand ISM"] # List of built-in Policy Initiatives to assign at top level. 
policy_initiatives_builtin_enable  = true                # Enable policy assignment (turns it on/off). 
policy_initiatives_builtin_enforce = false               # Enforce policy controls (audit vs enforce). 

policy_custom_allowed_locations = {
  effect = "Audit" # Audit, Deny, Disabled
  locations = [
    "australiaeast",
    "australiasoutheast",
    "newzealandnorth",
    "westus2"
  ]
}
policy_custom_required_tags = {
  effect = "Audit" # Audit, Deny, Disabled
  tags = [
    "Owner",
    "Environment",
    "Project"
  ]
}
