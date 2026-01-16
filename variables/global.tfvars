# SAFE TO COMMIT - Ensure no sensitive values are added.

# Global Variables
global = {
  locations = {
    default = "newzealandnorth"     # Default preferred location for IaC backend resources. 
    second  = "australiaeast"   # Secondary preference. 
  }
  naming = {  # Naming Convention - Example: "abc-plz-gov-logs-law"
    org_prefix  = "tjs"      # Short name of organization ("abc"). Used in resource naming.
    project     = "platform" # Project name for related resources (plz, platform, webapp01). 
    environment = "plz" # PLZ = Platform Landing Zone
  }
  tags = {
    Project     = "PlatformLandingZone"       # Name of the project. 
    Owner       = "CloudOps"         # Team responsible for the resources. 
    Creator     = "IaC-Terraform"       # Person or process that created the initial resources. 
    Environment = "SharedServices"   # Environment: Shared Services, prd, dev, tst
  }
}

# Repository Configuration
repo_config = {
  owner  = "tim-shand" # Org/owner, target repository, and branch name.
  repo   = "azure-platform-lz"
  branch = "main"
}
