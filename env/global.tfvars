# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

global = {
  location                  = "newzealandnorth" # Default preferred location for IaC backend resources. 
  global_outputs_table_name = "globaloutputs"   # Name of table containing global shared resource details.
}
naming = {
  prefix  = "tjs" # Short name of organization ("abc"). Used in resource naming.
  project = "plz" # Project name for related resources (plz, platform, webapp01). 
}
tags = {
  Project     = "PlatformLandingZone" # Name of the project. 
  Owner       = "CloudOps"            # Team responsible for the resources. 
  Creator     = "Terraform"           # Person or process that created the initial resources. 
  Environment = "Shared Services"     # Environment: Shared Services, prd, dev, tst
}
