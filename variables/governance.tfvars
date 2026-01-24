# General 
subscription_id = "8cf80f38-0042-413a-a0ac-c65663dda28e"
naming = {
  stack_name = "Governance" # Full stack name. Used with tag assignment and naming. 
  stack_code = "gov"        # Short code used for resource naming. 
}

# Management Groups 
management_group_root = {
  "core" = {
    display_name           = "TShand"          # Contains all platform subscriptions (management, connectivity, security and identity). 
    subscription_id_filter = []                # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    policy_initiatives     = ["core_baseline"] # Assign Policy Initiatives directly to MGs. 
  }
}
management_groups_level1 = { # Management Groups: First level nested under the root manangement group. 
  "platform" = {
    display_name           = "Platform"                                   # Contains all platform subscriptions (management, connectivity, security and identity). 
    subscription_id_filter = ["56effccd-9f6c-4b5e", "8cf80f38-0042-413a"] # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    policy_initiatives     = []                                           # Assign Policy Initiatives directly to MGs. 
  }
  "workloads" = {
    display_name           = "Workloads"       # Contains the landing zone child management groups for workloads. 
    subscription_id_filter = [""]              # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    policy_initiatives     = ["cost_controls"] # Assign Policy Initiatives directly to MGs. 
  }
  "sandbox" = {
    display_name           = "Sandbox"              # Contains subscriptions for testing. Isolated from corporate and online landing zones. Less restrictive set of policies assigned. 
    subscription_id_filter = ["66f229bc-adb1-4b24"] # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    policy_initiatives     = []                     # Assign Policy Initiatives directly to MGs
  }
  "decom" = {
    display_name           = "Decommissioned"   # Contains cancelled subscriptions. Deny resource creation via policy. 
    subscription_id_filter = []                 # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    policy_initiatives     = ["decommissioned"] # Assign Policy Initiatives directly to MGs. 
  }
}
management_groups_level2 = {
  "online" = {
    display_name           = "Online"               # Workloads requiring direct internet inbound or outbound connectivity, or may not require a virtual network.
    subscription_id_filter = ["9173fb12-e761-49ab"] # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    parent_mg_name         = "workloads"
    policy_initiatives     = [] # Assign Policy Initiatives directly to MGs. 
  }
  "corporate" = {
    display_name           = "Corporate" # Workloads that require connectivity with the corporate/on-prem network via the hub in the connectivity subscription. 
    subscription_id_filter = []          # List of subscription prefixes (first 3 segments). Maps MG to sub associationsm keeping full sub out of code.
    parent_mg_name         = "workloads"
    policy_initiatives     = [] # Assign Policy Initiatives directly to MGs. 
  }
}
management_groups_level3 = {} # Leave blank if not required. 
management_groups_level4 = {} # Leave blank if not required.
management_groups_level5 = {} # Leave blank if not required.

# Policy: Built-In 
policy_initiatives_builtin         = ["New Zealand ISM"] # List of built-in Policy Initiatives to assign at top level. 
policy_initiatives_builtin_enable  = true                # Enable policy assignment (turns it on/off). 
policy_initiatives_builtin_enforce = false               # Enforce policy controls (audit vs enforce). 

# Policy: Custom
policy_allowed_locations = ["newzealandnorth", "australiaeast", "westus", "westus2"]
policy_required_tags     = ["Owner", "Environment", "Project"]
policy_allowed_vm_skus = [
  "Standard_A1",
  "Standard_A2",
  "Standard_A3",
  "Standard_A1_v2",
  "Standard_A2_v2",
  "Standard_A4_v2",
  "Standard_B1s",
  "Standard_B2s",
  "Standard_B2s_v2",
  "Standard_B4s_v2",
  "Standard_D2_v3",
  "Standard_D4_v3"
]
policy_initiatives = { # Define Initiative -> Definition mapping. 
  core_baseline = [
    "allowed_locations",
    "required_tag_list",
    "storage_accounts_https"
  ]
  cost_controls = [
    "restrict_vm_skus"
  ]
  decommissioned = [
    "deny_all_resources"
  ]
}
