# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# NOTE: This is a Powershell data file that requires a specific format to be followed.
@{
    # Global: Naming, Resource and Tags
    global              = @{
        locations   = @{
            default   = "westus"          # Primary region to use for resource creation. 
            secondary = "australiaeast"   # Secondary region to use for resource creation. 
        }
        naming      = @{
            org_code     = "abc"      # Short code of the organisation, can be used with resource naming. 
            project_name = "platform" # Name of the project or workload: platform, mywebapp. 
            environment  = "plz"      # Workload environment: dev, tst, prd, alz. 
        }
        tags        = @{
            Organisation = "ABC Group"           # Name or abbreviation used to identify the organisation. 
            Owner        = "PlatformTeam"        # Name of the team that owns the project. 
            Environment  = "plz"                 # Workload environment: dev, tst, prd, alz, plz. 
            Project      = "PlatformLandingZone" # Project name, used to group and identify related resources. 
            CreatedBy    = "IaC-Terraform"       # Name of the user or service that created the resources. 
        }
        repo_config = @{
            org    = "my-org"             # Name of the repository organisation owner. 
            repo   = "azure-platform-lz"  # Repository where this project is stored. 
            branch = "main"               # Name of the default repository branch. 
        }
    }
    # Deployment Stacks
    subscription_id_iac = "00000000-1111-0000-0000-000000000000" # IaC Subscription 
    subscription_id_con = "00000000-5555-0000-5555-000000000000" # Connectivity Subscription 
    subscription_id_gov = "00000000-1111-0000-0000-000000000000" # Governance Subscription 
    subscription_id_mgt = "00000000-1111-0000-0000-000000000000" # Management Subscription 
    subscription_id_idn = "00000000-2222-0000-2222-000000000000" # Identity Subscription 
}
