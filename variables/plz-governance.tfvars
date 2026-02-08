# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                     # Map of name related variables (merge with "global.naming")
    workload_code = "gov"        # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Governance" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                              # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Project     = "PlatformLandingZone" # Workload/project name, used to group and identify related resources.
    Environment = "plz"                 # Workload environment: dev, tst, prd, alz, plz. 
    Owner       = "CloudOpsTeam"        # Name of the team that owns the project. 
    CostCenter  = "Platform"            # Useful for grouping resources for billing/financial accountability.
    Deployment  = "plz-governance"      # Workload/project name, used to group and identify related resources.
  }
}

# Management Groups: First level nested under the core manangement group.
management_group_core_policies = ["core_baseline"] # Direct assign policy initiatives to core management group. 
management_groups_level1 = {
  "platform" = {
    display_name             = "Platform"                               # Contains all platform subscriptions (management, connectivity, security and identity). 
    subscription_identifiers = ["platform-iac-sub", "platform-plz-sub"] # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = []                                       # Assign Policy Initiatives directly to MGs. 
  }
  "workload" = {
    display_name             = "Workload"        # Contains the landing zone child management groups for workloads. 
    subscription_identifiers = []                # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = ["cost_controls"] # Assign Policy Initiatives directly to MGs. 
  }
  "sandbox" = {
    display_name             = "Sandbox"                # Contains subscriptions for testing. Isolated from corporate and online landing zones. Less restrictive set of policies assigned. 
    subscription_identifiers = ["visualstudio-dev-sub"] # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = []                       # Assign Policy Initiatives directly to MGs
  }
  "decom" = {
    display_name             = "Decommissioned"   # Contains cancelled subscriptions. Deny resource creation via policy. 
    subscription_identifiers = []                 # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
    policy_initiatives       = ["decommissioned"] # Assign Policy Initiatives directly to MGs. 
  }
}

# Management Groups: Second level nested under level 1 manangement groups.
management_groups_level2 = {
  "online" = {
    display_name             = "Online" # Workloads requiring direct internet inbound or outbound connectivity, or may not require a virtual network.
    parent_mg_name           = "workload"
    subscription_identifiers = ["tshandcom-prd-sub"] # List of subscription prefixes (first 3 segments). Maps MG to sub associations keeping full sub out of code.
    policy_initiatives       = []                    # Assign Policy Initiatives directly to MGs. 
  }
  "corporate" = {
    display_name             = "Corporate" # Workloads that require connectivity with the corporate/on-prem network via the hub in the connectivity subscription. 
    parent_mg_name           = "workload"
    subscription_identifiers = [] # List of subscription prefixes (first 3 segments). Maps MG to sub associations keeping full sub out of code.
    policy_initiatives       = [] # Assign Policy Initiatives directly to MGs. 
  }
}
# Management Groups: Third level nested under level 2 manangement groups.
management_groups_level3 = {} # Leave blank if not required. Repeat same structure as "management_groups_level2". 

# Policy: Built-In 
policy_initiatives_builtin = {
  "New Zealand ISM" = {
    definition_id    = "4f5b1359-4f8e-4d7c-9733-ea47fcde891e" # ID of the initiative (4f5b1359-4f8e-4d7c-9733-ea47fcde891e). 
    assignment_mg_id = "core"                                 # Short code for Management Group ID to assign the initiative to (see 'management_group_registry'). 
    enabled          = true                                   # [true/false]: Toggle assignment.  
    enforce          = false                                  # [true/false]: Toggle enforcement of policy initiative. 
  }
}

# Policy: Custom
policy_enforce_mode = "audit" # DeployIfNotExists, Disabled
policy_initiatives = {        # Define Initiative --> Definition mapping. 
  core_baseline = [
    "allowed_locations",
    "required_tag_list",
    "storage_accounts_https",
    "diagnostic_settings_all"
  ]
  cost_controls = [
    "restrict_vm_skus"
  ]
  decommissioned = [
    "deny_all_resources"
  ]
}
policy_var_allowed_locations = ["newzealandnorth", "australiaeast", "westus", "westus2"]
policy_var_required_tags     = ["Owner", "Environment", "Project"]
policy_var_allowed_vm_skus = [
  "Standard_A1_v2",
  "Standard_A2_v2",
  "Standard_A4_v2",
  "Standard_B1ls",
  "Standard_B1s",
  "Standard_B1ms",
  "Standard_B2s",
  "Standard_B2ms",
  "Standard_B4s",
  "Standard_B4ms",
  "Standard_B4s_v2",
  "Standard_D2_v4",
  "Standard_D2s_v4",
  "Standard_D4_v4",
  "Standard_D4s_v4"
]
