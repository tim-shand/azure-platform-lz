# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# General / Azure
location = "westus2" # SWA is limited regions for free-tier.
naming = {
    prefix = "tjs" # Short name of organization ("abc").
    platform = "app" # Platform name for related resources ("mgt", "plz").
    project = "wwwtshandcom" # Project name for related resources ("platform", "landingzone").
    service = "swa" # Service name used in the project ("iac", "mgt", "sec").
    environment = "prd" # Environment for resources/project ("dev", "tst", "prd", "alz").
}
tags = {
    Project = "wwwtshandcom" # Name of the project the resources are for.
    Environment = "prd" # dev, tst, prd, alz
    Owner = "CloudOps" # Team responsible for the resources.
}

# GitHub
github_config = {
  "owner" = "tim-shand" # Repository owner/org. 
  "infra_repo" = "homelab" # Repository where infra is generated. 
  "src_repo" = "www-tshand-com" # Repository where source code is located. 
}

# SWA
custom_domain_name = "www.tshand.com"
