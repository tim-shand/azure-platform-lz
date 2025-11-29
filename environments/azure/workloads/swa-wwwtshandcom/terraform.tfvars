# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# General / Azure
location = "westus2" # SWA has limited regions for free-tier.
naming = {
  prefix  = "tjs"          # Short name of organization ("abc").
  service = "web"          # Service name used in the project ("iac", "mgt", "sec").
  project = "wwwtshandcom" # Project name for related resources ("platform", "webapp01").
}
tags = {
  Project = "Personal-Website" # Name of the project the resources are for.
  Owner   = "CloudOps"         # Team responsible for the resources.
}
project_groups = [
  "Project_RBAC_wwwtshandcom_Admin" # Must already exist in Entra. 
]
