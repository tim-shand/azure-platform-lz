# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# General: Azure and GitHub Configuration ---------------------------------|
global = {
  location    = "newzealandnorth" # Default preferred location for IaC backend resources. 
}
naming = {
  prefix      = "tjs"  # Short name of organization ("abc"). Used in resource naming.
  project     = "platform" # Project name for related resources (platform, webapp01). 
  service     = "iac" # Service name used in the project (gov, con, sec, mgt, wrk). 
  environment = "prd" # Environment for resources/project (dev, tst, prd, sys).
}
tags = {
  Environment = "prd" # dev, tst, prd. 
  Project     = "PlatformLandingZone" # Name of the project. 
  Owner       = "CloudOps" # Team responsible for the resources. 
  Creator     = "Bootstrap" # Person or process that created the initial resources. 
}
repo_config = {
  owner  = "tim-shand" # Org/owner, target repository, and branch name.
  repo   = "azure-platform-lz"
  branch = "main"
}

# Stacks: Configuration ---------------------------------|
deployment_stacks = {
  bootstrap = {
      bootstrap = {
      stack_name        = "iac-bootstrap"
      subscription_id   = "56effccd-9f6c-4b5e-8747-3f24a1d2dcc3"
      create_repo_env = false # No need for separate bootstrap environment in GitHub. 
    }
  }
  platform = {
    connectivity = {
      stack_name        = "plz-connectivity"
      subscription_id   = "8cf80f38-0042-413a-a0ac-c65663dda28e"
      create_repo_env = true
    }
    governance = {
      stack_name        = "plz-governance"
      subscription_id   = "8cf80f38-0042-413a-a0ac-c65663dda28e"
      create_repo_env = true
    }
    management = {
      stack_name        = "plz-management"
      subscription_id   = "8cf80f38-0042-413a-a0ac-c65663dda28e"
      create_repo_env = true
    }
    identity = {
      stack_name        = "plz-identity"
      subscription_id   = "8cf80f38-0042-413a-a0ac-c65663dda28e"
      create_repo_env = true
    }
  }
  workloads = {
    # Placeholder to ensure resource group and storage account structure is created. 
    # To be used in future for workload IaC Backend Vending. 
  }
}
