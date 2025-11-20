# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# General
location = "newzealandnorth"
naming = {
    prefix = "tjs" # Short name of organization ("abc").
    platform = "plz" # Platform name for related resources ("mgt", "plz").
    project = "platform" # Project name for related resources ("platform", "landingzone").
    service = "mgt" # Service name used in the project ("iac", "mgt", "sec").
    environment = "prd" # Environment for resources/project ("dev", "tst", "prd", "alz").
}

# Tags (assigned to all bootstrap resources).
tags = {
    Project = "Platform" # Name of the project the resources are for.
    Environment = "prd" # dev, tst, prd, alz
    Owner = "CloudOps" # Team responsible for the resources.
}

# Object of Management Groups to create.
plz_management_groups = {
  "platform" = { 
    mg_display_name = "Platform" # Insert subscriptions here at runtime.
  }
  "workloads" = { 
    mg_display_name = "Workloads"
  }
  "sandbox" = { 
    mg_display_name = "Sandbox"
  }
  "decom" = { 
    mg_display_name = "Decommissioned"
  }
}
