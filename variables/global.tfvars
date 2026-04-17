# GLOBAL ------------------------------------------------------------- #
# Map of global variables used across multiple deployment stacks. 
terraform_version = "1.14.0" # Version of Terraform to use in automation workflows.
global = {
  naming = {                 # Map of name related variables (merge with "stack.naming"). 
    org_prefix       = "tjs" # Organization abbreviated name. Example: "abc" (Azure Balloon Company).
    workload_project = "plz" # Workload project, overall category or additional grouping name. 
  }
  location = {
    primary   = "newzealandnorth" # Default, preferred location. 
    secondary = "australiaeast"   # Secondary location for resources not available in primary region.
  }
  tags = {
    Organization = "TShandCom"           # Name or abbreviation used to identify the organisation.  
    CreatedBy    = "IaC-Terraform"       # Name of the user or service that created the resources. 
    Project      = "PlatformLandingZone" # Workload/project name, used to group and identify related resources.
    Environment  = "plz"                 # alz, plz, dev, tst, prd.
  }
  repo_config = {
    org    = "tim-shand"         # Name of the repository organization owner. 
    repo   = "azure-platform-lz" # Repository where this project is stored. 
    branch = "main"              # Name of the default repository branch. 
  }
  # management_group_core = {
  #   short_name   = "core"     # Used for the reference name of the core Management Group.
  #   display_name = "TimShand" # Full display name of the core Management Group.
  # }
}

# DEPLOYMENT STACKS / REMOTE STATES ------------------------------------------------------------- #
# Define stacks and their configuration used to deploy resources.
# Used to access resources in state files across other stacks.

deployment_stacks = {
    "bootstrap" = {
      stack_name              = "iac-bootstrap"       # Name of stack directory and GitHub environment.
      stack_code              = "iac"                 # Short code for the stack name.
      subscription_identifier = "platform-iac-sub"    # String value used with lookup matching for subscription display name (full or partial).
      enable_github_env       = false                 # NOT REQUIRED FOR BOOTSTRAP.
    },
    "management" = {
      stack_name              = "plz-management"
      stack_code              = "mgt"
      subscription_identifier = "platform-dev-sub"
      enable_github_env       = true                  # Create GitHub environment for stack (true/false).
    },
    "governance" = {
      stack_name              = "plz-governance"
      stack_code              = "gov"
      subscription_identifier = "platform-dev-sub"
      enable_github_env       = true
    },
    "connectivity" = {
      stack_name              = "plz-connectivity"
      stack_code              = "con"
      subscription_identifier = "platform-dev-sub"
      enable_github_env       = true
    }
}
