# Global: Map of global variables used across multiple deployment stacks. 
global = {
  naming = {           # Map of name related variables (merge with "stack.naming"). 
    org_prefix = "tjs" # Organisation abbreviated name. Example: "abc" (Azure Balloon Company).
  }
  location = {
    primary   = "newzealandnorth" # Default, preferred location. 
    secondary = "australiaeast"   # Secondary location for resources not available in primary region. 
  }
  tags = {
    Organisation = "TimShand"      # Name or abbreviation used to identify the organisation.  
    CreatedBy    = "IaC-Terraform" # Name of the user or service that created the resources. 
  }
  repo_config = {
    org    = "tim-shand"         # Name of the repository organisation owner. 
    repo   = "azure-platform-lz" # Repository where this project is stored. 
    branch = "main"              # Name of the default repository branch. 
  }
}

# Management Groups: Core (Top Level)
management_group_core_id           = "core"     # Management Group ID used for resource naming.  
management_group_core_display_name = "TimShand" # Management Group display name.  
