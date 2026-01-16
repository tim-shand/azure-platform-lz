# General -----------------#

stack_name = "Governance" # Full stack name. Used with tag assignment and naming. 
stack_code = "gov"        # Short code used for resource naming. 

# Governance: Management Groups -----------------#

management_group_root = "Core" # Top level Management Group name.
management_group_list = {
  platform = {                           # Platform Landing Zone
    display_name            = "Platform" # Cosmetic name for Management Group.
    subscription_identifier = "plz"      # Used to identify existing subscriptions to add to the Management Groups. 
    sub_groups              = {}         # No child management groups required. 
  }
  workloads = { # Workloads
    display_name            = "Workloads"
    subscription_identifier = "app" # If subscription name contains, then auto-group under this management group.
    sub_groups = {                  # Define child management groups to be contaiend under this second level MG.
      production = {
        display_name            = "Production"
        subscription_identifier = "prd" # If subscription name contains, then auto-group under this management group.
      }
      development = {
        display_name            = "Development"
        subscription_identifier = "dev" # If subscription name contains, then auto-group under this management group.
      }
    }
  }
  sandbox = { # Testing Environment
    display_name            = "Sandbox"
    subscription_identifier = "tst"
    sub_groups              = {} # No child management groups required.
  }
  decom = { # Decommission Subscriptions
    display_name            = "Decommission"
    subscription_identifier = "decom"
    sub_groups              = {} # No child management groups required.
  }
}

# Governance: Policy Assignments -----------------#

policy_builtin_initiatives = ["New Zealand ISM"]
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
