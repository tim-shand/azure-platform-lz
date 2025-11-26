# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# NOTE: This is a Powershell data file that requires a specific format to be followed.
@{
    # Azure
    Azure = @{
        Location = "westus2" # Default preferred location for IaC backend resources.
        SubscriptionIAC = "123456-1234-1234-123456-1234" # Subscription: IaC
        Naming = @{
            Environment = "prd" # Environment for resources/project (dev, tst, prd).
            Prefix = "abc" # Short name of organization ("abc"). Used in resource naming.
            Service = "mgt" # Service name used in the project (gov, con, sec, mgt, wrk).
            Project = "iac" # Project name for related resources (platform, webapp01).    
        }
        Tags = @{
            Environment = "prd" # dev, tst, prd.
            Project = "Platform" # Name of the project the resources are for.
            Owner = "CloudOps" # Team responsible for the resources.
            Creator = "Bootstrap" # Person or process that created the initial resources.
        }
    }

    # GitHub: Org/owner, target repository, and branch name.
    GitHub = @{
        Owner = "my-org"
        Repo = "repo-name"
        Branch = "main"
    }
}
