# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# General: Azure and GitHub Configuration ---------------------------------|

# General -----------------#
naming = {
  stack_name = "Bootstrap" # Full stack name. Used with tag assignment and naming. 
  stack_code = "iac"       # Short code used for resource naming. 
}
tags = {
  Deployment = "Bootstrap" # Deployment specific tags (merged with global tags). 
}

# Stacks: Configuration ---------------------------------|
deployment_stacks = {
  bootstrap = {
    category        = "bootstrap"
    stack_name      = "iac-bootstrap"
    subscription_id = "56effccd-9f6c-4b5e-8747-3f24a1d2dcc3"
    create_repo_env = false
  }
  connectivity = {
    category        = "platform"
    stack_name      = "plz-connectivity"
    subscription_id = "8cf80f38-0042-413a-a0ac-c65663dda28e"
    create_repo_env = true
  }
  governance = {
    category        = "platform"
    stack_name      = "plz-governance"
    subscription_id = "8cf80f38-0042-413a-a0ac-c65663dda28e"
    create_repo_env = true
  }
  management = {
    category        = "platform"
    stack_name      = "plz-management"
    subscription_id = "8cf80f38-0042-413a-a0ac-c65663dda28e"
    create_repo_env = true
  }
  identity = {
    category        = "platform"
    stack_name      = "plz-identity"
    subscription_id = "8cf80f38-0042-413a-a0ac-c65663dda28e"
    create_repo_env = true
  }
}
