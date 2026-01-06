# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# NOTE: This is a Powershell data file that requires a specific format to be followed.
@{
    # General: Azure and Repo Configuration ---------------------------------|
    global      = @{
        location                      = "westus2" # Default preferred location for IaC backend resources. 
        subscription_iac_bootstrap    = "1a2b3c4d-1234-abcd-1234-1a2b3c4d5e6f"
        subscription_plz_connectivity = "1a2b3c4d-1234-abcd-1234-1a2b3c4d5e6f"
        subscription_plz_governance   = "1a2b3c4d-1234-abcd-1234-1a2b3c4d5e6f"
        subscription_plz_management   = "1a2b3c4d-1234-abcd-1234-1a2b3c4d5e6f"
        subscription_plz_identity     = "1a2b3c4d-1234-abcd-1234-1a2b3c4d5e6f"
    }
    naming      = @{
        prefix      = "abc"      # Short acronym name of organization ("abc"). Used in resource naming.
        project     = "platform" # Project name for related resources (platform, webapp01). 
        service     = "iac"      # Service name used in the project (gov, con, sec, mgt, wrk). 
        environment = "prd"      # Environment for resources/project (dev, tst, prd, sys).
    }
    tags        = @{
        Environment = "prd"                 # dev, tst, prd. 
        Project     = "PlatformLandingZone" # Name of the project. 
        Owner       = "CloudOps"            # Team responsible for the resources. 
        Creator     = "Bootstrap"           # Person or process that created the initial resources. 
    }
    repo_config = @{
        owner  = "my-org" # Org/owner, target repository, and branch name.
        repo   = "azure-platform-lz"
        branch = "main"
    }
}
