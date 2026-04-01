# Global: Map of global variables used across multiple deployment stacks. 
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
  }
  repo_config = {
    org    = "tim-shand"         # Name of the repository organization owner. 
    repo   = "azure-platform-lz" # Repository where this project is stored. 
    branch = "main"              # Name of the default repository branch. 
  }
}
