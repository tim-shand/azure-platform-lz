# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {              # Map of name related variables (merge with "global.naming")
    workload_code = "iac" # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "iac" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                              # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Project     = "PlatformLandingZone" # Workload/project name, used to group and identify related resources.
    Environment = "plz"                 # Workload environment: dev, tst, prd, alz, plz. 
    Owner       = "CloudOpsTeam"        # Name of the team that owns the project. 
    CostCenter  = "Platform"            # Useful for grouping resources for billing/financial accountability.
    Deployment  = "iac-bootstrap"       # Workload/project name, used to group and identify related resources.
  }
}

# Management Groups: Core (Top Level)
management_group_core_id           = "core"     # Management Group ID used for resource naming.  
management_group_core_display_name = "TimShand" # Management Group display name.  

# Deployment Stacks: Map of objects representing the platform workloads to provision. 
backend_categories = ["bootstrap", "platform", "workloads"] # Used to group backend resources by deployment category. 
platform_stacks = {
  # "example-connectivity" = {
  #   stack_name              = "dev-connectivity" # STATIC: Name of stack directory and GitHub environment. 
  #   stack_category          = "platform"         # Deployment Category: platform, workload, bootstrap. 
  #   subscription_identifier = "con-sub"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.  
  # },
  "connectivity" = {
    stack_name              = "plz-connectivity" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"         # Backend Category: platform, workload, bootstrap. 
    subscription_identifier = "platform"         # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.  
  },
  "governance" = {
    stack_name              = "plz-governance" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"       # Backend Category: platform, workload, bootstrap.
    subscription_identifier = "platform"       # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.
  },
  "management" = {
    stack_name              = "plz-management" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"       # Backend Category: platform, workload, bootstrap. 
    subscription_identifier = "platform"       # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
  },
  "identity" = {
    stack_name              = "plz-identity" # STATIC: Name of stack directory and GitHub environment.  
    stack_category          = "platform"     # Backend Category: platform, workload, bootstrap.
    subscription_identifier = "platform"     # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
  }
}

workload_stacks = {
  # Placeholder for future deployments. Use the same structure and format as "platform_stacks". 
  # Example:
  # "mywebapp" = {
  #   stack_name        = "mywebapp-prd" 
  #   subscription_name = "workloads-prd-sub" 
  # }
}
