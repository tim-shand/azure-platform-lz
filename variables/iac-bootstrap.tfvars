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

# Backend Categories: Define the top-level IaC backend structure. NOTE: Opinionated (DO NOT change key structure). 
backend_categories = {
  bootstrap = "bootstrap" # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
  platform  = "platform"  # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
  workload  = "workload"  # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
}

# Deployment Stacks: Map of objects representing the platform workloads to provision. 
platform_stacks = {
  "bootstrap" = {
    stack_name              = "iac-bootstrap"    # Name of stack directory and GitHub environment. 
    backend_category        = "bootstrap"        # Backend Category [backend_categories]: bootstrap, platform, workload. 
    subscription_identifier = "platform-iac-sub" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_environment      = false              # Enable to create related environment in GitHub for stack.  
  },
  "connectivity" = {
    stack_name              = "plz-connectivity" # Name of stack directory and GitHub environment. 
    backend_category        = "platform"         # Backend Category [backend_categories]: bootstrap, platform, workload. 
    subscription_identifier = "platform-plz-sub" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_environment      = true               # Enable to create related environment in GitHub for stack.  
  },
  "governance" = {
    stack_name              = "plz-governance"   # Name of stack directory and GitHub environment. 
    backend_category        = "platform"         # Backend Category [backend_categories]: bootstrap, platform, workload. 
    subscription_identifier = "platform-plz-sub" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.
    create_environment      = true               # Enable to create related environment in GitHub for stack. 
  },
  "management" = {
    stack_name              = "plz-management"   # Name of stack directory and GitHub environment. 
    backend_category        = "platform"         # Backend Category [backend_categories]: bootstrap, platform, workload.  
    subscription_identifier = "platform-plz-sub" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_environment      = true               # Enable to create related environment in GitHub for stack. 
  },
  "identity" = {
    stack_name              = "plz-identity"     # Name of stack directory and GitHub environment.  
    backend_category        = "platform"         # Backend Category [backend_categories]: bootstrap, platform, workload. 
    subscription_identifier = "platform-plz-sub" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_environment      = true               # Enable to create related environment in GitHub for stack. 
  }
}
