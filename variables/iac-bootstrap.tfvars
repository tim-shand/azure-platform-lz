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
platform_stacks = {
  # "example-connectivity" = {
  #   stack_name              = "dev-connectivity" # Name of stack directory and GitHub environment. 
  #   stack_category          = "platform"         # Deployment Category: platform, workload, global/bootstrap. 
  #   subscription_identifier = "con-sub"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.  
  # },
  "bootstrap" = {
    stack_name              = "iac-bootstrap" # Name of stack directory and GitHub environment. 
    stack_category          = "global"        # Backend Category: platform, workload, global/bootstrap. 
    subscription_identifier = "iac-sub"       # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = false           # Enable to create related environment in GitHub for stack (NOT required for bootstrap/global). 
    prevent_delete          = true            # Enable to prevent this stacks resource from being deleted. 
  },
  "connectivity" = {
    stack_name              = "plz-connectivity" # Name of stack directory and GitHub environment. 
    stack_category          = "platform"         # Backend Category: platform, workload, global/bootstrapl. 
    subscription_identifier = "plz-sub"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = true               # Enable to create related environment in GitHub for stack.  
    prevent_delete          = false              # Enable to prevent this stacks resource from being deleted. 
  },
  "governance" = {
    stack_name              = "plz-governance" # Name of stack directory and GitHub environment. 
    stack_category          = "platform"       # Backend Category: platform, workload, global/bootstrap.
    subscription_identifier = "plz-sub"        # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.
    create_env              = true             # Enable to create related environment in GitHub for stack. 
    prevent_delete          = false            # Enable to prevent this stacks resource from being deleted. 
  },
  "management" = {
    stack_name              = "plz-management" # Name of stack directory and GitHub environment. 
    stack_category          = "platform"       # Backend Category: platform, workload, global/bootstrap. 
    subscription_identifier = "plz-sub"        # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = true             # Enable to create related environment in GitHub for stack. 
    prevent_delete          = false            # Enable to prevent this stacks resource from being deleted. 
  },
  "identity" = {
    stack_name              = "plz-identity" # Name of stack directory and GitHub environment.  
    stack_category          = "platform"     # Backend Category: platform, workload, global/bootstrap.
    subscription_identifier = "plz-sub"      # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = true           # Enable to create related environment in GitHub for stack. 
    prevent_destroy         = false          # Enable to prevent this stacks resource from being deleted. 
  }
}

# Workload Stacks: Used to deploy workload backend resources. 
workload_stacks = {
  "example" = {
    stack_name              = "app-example"          # Name of stack directory and GitHub environment.  
    stack_category          = "workloads"            # Backend Category: platform, workload, global/bootstrap.
    subscription_identifier = "visualstudio-dev-sub" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
  }
}
