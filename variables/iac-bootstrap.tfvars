# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                    # Map of name related variables (merge with "global.naming")
    workload_code = "iac"       # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "bootstrap" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                       # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Owner      = "CloudOpsTeam"  # Name of the team that owns the project. 
    CostCenter = "Platform"      # Useful for grouping resources for billing/financial accountability.
    Deployment = "iac-bootstrap" # Workload/project name, used to group and identify related resources.
  }
}

# Management Group CORE: Top level nested under the tenant root. 
management_group_core = {
  name         = "core"     # Short name used to make up naming structure. 
  display_name = "TimShand" # Top-level Management Group representing the organisation.  
}

# Deployment Stacks: Map of objects representing the platform workloads to provision. 
platform_stacks = {
  "bootstrap" = {
    stack_name              = "iac-bootstrap"      # Name of stack directory and GitHub environment.
    stack_code              = "iac"                # Short code for the stack name.
    subscription_identifier = "56effccd-9f6c-4b5e" # Subscription ID part, resolved to full ID in data call.
  },
  "connectivity" = {
    stack_name              = "plz-connectivity"   # Name of stack directory and GitHub environment.
    stack_code              = "con"                # Short code for the stack name.
    subscription_identifier = "8cf80f38-0042-413a" # Subscription ID part, resolved to full ID in data call.
  },
  "governance" = {
    stack_name              = "plz-governance"
    stack_code              = "gov"
    subscription_identifier = "8cf80f38-0042-413a"
  },
  "management" = {
    stack_name              = "plz-management"
    stack_code              = "mgt"
    subscription_identifier = "8cf80f38-0042-413a"
  }
}
