# GENERAL ---------------------------------------------------- #

# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                     # Map of name related variables (merge with "global.naming")
    workload_code = "gov"        # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Governance" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                        # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Owner      = "CloudOpsTeam"   # Name of the team that owns the project. 
    CostCenter = "Platform"       # Useful for grouping resources for billing/financial accountability.
    Deployment = "plz-governance" # Workload/project name, used to group and identify related resources.
  }
}

# MANAGEMENT GROUPS ------------------------------------------- #

# Management Groups: First level nested under core management group.
management_groups_level1 = {
  "platform" = {
    display_name             = "Platform"                        
    parent_mg_name           = "core"                           # Key ID of the parent Management Group. 
    subscription_identifiers = ["platform-prd", "platform-iac"] # List of subscription name identifiers. Maps MG to sub associations keeping sub ID out of code.
  }
  "workload" = {
    display_name             = "Workload"
    parent_mg_name           = "core"
    subscription_identifiers = ["tshandcom-prd-sub"]
  }
  "sandbox" = {
    display_name             = "Sandbox" 
    parent_mg_name           = "core"
    subscription_identifiers = ["vsccl-dev-sub"]
  }
  "decom" = {
    display_name             = "Decommissioned"
    parent_mg_name           = "core" 
    subscription_identifiers = []
  }
}

# Management Groups: Second level nested under level 1 management groups.
management_groups_level2 = {} # Leave blank if not required. Repeat same structure as "management_groups_level1". 

# Management Groups: Third level nested under level 2 management groups.
management_groups_level3 = {} # Leave blank if not required. Repeat same structure as "management_groups_level2". 

# POLICY ------------------------------------------- #

# Policy: Built-In Initiatives
policy_initiatives_builtin = {
  "New Zealand ISM" = {
    definition_id = "4f5b1359-4f8e-4d7c-9733-ea47fcde891e" # ID of the initiative. 
    enabled       = true                                   # [true/false]: Toggle assignment.  
    enforce       = false                                  # [true/false]: Toggle enforcement of policy initiative. 
  }
}

policy_enforce_mode = false

# Policy (Custom): Parameters
policy_param_allowed_locations = [
    "newzealandnorth", 
    "australiaeast", 
    "westus", 
    "westus2"
]
policy_param_required_tags     = [
    "Owner", 
    "Environment", 
    "Project"
]
policy_param_allowed_vm_skus = [
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

# Assignments -------------------------- #

# See locals.tf for dynamic assignments with parameters passed as variables.
