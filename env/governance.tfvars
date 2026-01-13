# Governance: General -----------------#

subscription_id = "8cf80f38-0042-413a-a0ac-c65663dda28e" # TEMP
stack_code      = "gov"                                  # Short code used for resource naming. 

# Governance: Management Groups -----------------#

management_group_root = "Core" # Top level Management Group name.
management_group_list = {
  platform = {
    display_name            = "Platform" # Cosmetic name for Management Group.
    subscription_identifier = "plz"      # Used to identify existing subscriptions to add to the Management Groups. 
  }
  workloads = {
    display_name            = "Workloads"
    subscription_identifier = "app"
  }
  sandbox = {
    display_name            = "Sandbox"
    subscription_identifier = "dev"
  }
  decom = {
    display_name            = "Decommission"
    subscription_identifier = "decom"
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
