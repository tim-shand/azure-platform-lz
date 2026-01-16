# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# NOTE: This is a Powershell data file that requires a specific format to be followed.
@{
    # Global: Naming, Resource and Tags
    global = @{
        locations = @{
            default = "westus" # Default preferred location for IaC backend resources. 
            secondary  = "westus2"   # Secondary preference.
        }
        naming = @{                 # Naming Convention - Example: "abc-plz-gov-logs-law"
            org_prefix  = "abc"      # Short name of organization ("abc"). Used in resource naming.
            project     = "platform" # Project name for related resources (plz, platform, webapp01). 
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
        owner  = "my-org" # Org/owner, target repository, and branch name.
        repo   = "repo-name"
        branch = "main"
    }

    # Deployment Stacks
    subscription_iac_id = "12345678-0000-0000-0000-000000000000" # IaC Subscription
    subscription_con_id = "12345678-0000-0000-0000-000000000000" # Connectivity Subscription
    subscription_gov_id = "12345678-0000-0000-0000-000000000000" # Governance Subscription
    subscription_mgt_id = "12345678-0000-0000-0000-000000000000" # Management Subscription
    subscription_idn_id = "12345678-0000-0000-0000-000000000000" # Identity Subscription
}
