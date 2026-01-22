# Variables: Global
global = {
  locations = {
    default   = "newzealandnorth"   # Primary region to use for resource creation. 
    secondary = "australiaeast" # Secondary region to use for resource creation. 
  }
  naming = {
    org_code     = "tjs"      # Short code of the organisation, can be used with resource naming. 
    project_name = "platform"  # Name of the project or workload: platform, mywebapp. 
    environment  = "plz"   # Workload environment: dev, tst, prd, alz. 
  }
  tags = {
    Organisation = "TJS" # Name or abbreviation used to identify the organisation. 
    Owner        = "PlatformTeam"        # Name of the team that owns the project. 
    Environment  = "plz"  # Workload environment: dev, tst, prd, alz, plz. 
    Project      = "PlatformLandingZone"      # Project name, used to group and identify related resources. 
    CreatedBy    = "IaC-Terraform"    # Name of the user or service that created the resources. 
  }
  repo_config = {
    org    = "tim-shand"    # Name of the repository organisation owner. 
    repo   = "azure-platform-lz"   # Repository where this project is stored. 
    branch = "main" # Name of the default repository branch. 
  }
}
