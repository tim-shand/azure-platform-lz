# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# General
location = "newzealandnorth"
naming = {
  org         = "tjs"      # Short name of organization (abc).
  service     = "plz"      # Service name used in the project (iac, mgt, sec).
  project     = "platform" # Project name for related resources (platform, landingzone).
  environment = "prd"
}

# Tags (assigned to all bootstrap resources).
tags = {
  Project     = "PlatformLandingZone" # Name of the project the resources are for.
  Owner       = "CloudOps"            # Team responsible for the resources.
  Environment = "prd"
}
