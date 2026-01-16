# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in GitHub Secrets or environment variables.

# Global Variables
global = {
  location = "newzealandnorth" # Default preferred location for IaC backend resources. 
  naming = {                   # Naming Convention - Example: "tjs-plz-gov-logs-law"
    prefix  = "tjs"            # Short name of organization ("abc"). Used in resource naming.
    project = "plz"            # Project name for related resources (plz, platform, webapp01). 
  }
  tags = {
    Project     = "PlatformLandingZone" # Name of the project. 
    Owner       = "CloudOps"            # Team responsible for the resources. 
    Creator     = "IaC-Terraform"       # Person or process that created the initial resources. 
    Environment = "SharedServices"      # Environment: Shared Services, prd, dev, tst
  }
}

# Repository Configuration
repo_config = {
  owner  = "tim-shand" # Org/owner, target repository, and branch name.
  repo   = "azure-platform-lz"
  branch = "main"
}
