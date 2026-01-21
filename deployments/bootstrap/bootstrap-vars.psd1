# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# NOTE: This is a Powershell data file that requires a specific format to be followed.
@{
    # Global: Naming, Resource and Tags
    global = @{
        locations = @{
            default = "newzealandnorth" # Default preferred location for IaC backend resources. 
            secondary  = "australiaeast"   # Secondary preference.
        }
        naming = @{                 # Naming Convention - Example: "abc-plz-gov-logs-law"
            org_prefix  = "tjs"      # Short name of organization ("abc"). Used in resource naming.
            project_long  = "platform"  # Project name (long) for related resources (platform, webapp01). 
            project_short = "plz"       # Project name (short) for related resources (plz, app).
            environment = "plz"
        }
        tags = @{
            Project     = "PlatformLandingZone" # Name of the project. 
            Owner       = "CloudOps"            # Team responsible for the resources. 
            Creator     = "IaC-Terraform"       # Person or process that created the initial resources. 
            Environment = "SharedServices"      # Environment: Shared Services, prd, dev, tst
        }
    }
    
    # Repository Configuration
    repo_config = @{
        owner  = "tim-shand" # Org/owner, target repository, and branch name.
        repo   = "azure-platform-lz"
        branch = "main"
    }

    # Deployment Stacks
    subscription_iac_id = "56effccd-9f6c-4b5e-8747-3f24a1d2dcc3" # IaC Subscription
    subscription_con_id = "8cf80f38-0042-413a-a0ac-c65663dda28e" # Connectivity Subscription
    subscription_gov_id = "8cf80f38-0042-413a-a0ac-c65663dda28e" # Governance Subscription
    subscription_mgt_id = "8cf80f38-0042-413a-a0ac-c65663dda28e" # Management Subscription
    subscription_idn_id = "8cf80f38-0042-413a-a0ac-c65663dda28e" # Identity Subscription
}
