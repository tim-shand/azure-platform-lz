# Global: Map of global variables used across multiple deployment stacks. 
global = {
  naming = {                      # Map of name related variables (merge with "stack.naming"). 
    org_prefix       = "tjs"      # Organisation abbreviated name. Example: "abc" (Azure Balloon Company).
    workload_project = "platform" # Workload project, overall category or additional grouping name. 
  }
  location = {
    primary   = "newzealandnorth" # Default, preferred location. 
    secondary = "australiaeast"   # Secondary location for resources not available in primary region. 
  }
  tags = {
    Organisation = "TimShand"            # Name or abbreviation used to identify the organisation.  
    CreatedBy    = "IaC-Terraform"       # Name of the user or service that created the resources. 
    Project      = "PlatformLandingZone" # Workload/project name, used to group and identify related resources.
    Environment  = "plz"                 # Workload environment: dev, tst, prd, alz, plz. 
  }
  repo_config = {
    org    = "tim-shand"         # Name of the repository organisation owner. 
    repo   = "azure-platform-lz" # Repository where this project is stored. 
    branch = "main"              # Name of the default repository branch. 
  }
}

# Global Outputs: Map of Shared Services and the key name containing the value in global outputs.  
# [DO NOT MODIFY]
global_outputs = {
  # Subscriptions
  # plz_sub_governance_id   = "sub-plz-governance-id"   # Subscription ID: Governance
  # plz_sub_identity_id     = "sub-plz-identity-id"     # Subscription ID: Identity
  # plz_sub_management_id   = "sub-plz-management-id"   # Subscription ID: Management
  # plz_sub_connectivity_id = "sub-plz-connectivity-id" # Subscription ID: Connectivity
  # Workflow
  plz_service_principal_appid = "iac-service-principal-appid" # Pipeline Service Principal name. 
  plz_service_principal_name  = "iac-service-principal-name"  # Pipeline Service Principal name.
  # Governance
  plz_core_mg_id   = "gov-management-group-core-id"   # Shared Services: Top-level Management Group. 
  plz_core_mg_name = "gov-management-group-core-name" # Shared Services: Top-level Management Group. 
  # Management/Logging
  plz_mgt_law_id = "mgt-logging-law-id" # Shared Services: Log Analytics Workspace ID. 
  plz_mgt_sa_id  = "mgt-logging-sa-id"  # Shared Services: Storage Account ID. 
  # Connectivity
  plz_hub_vnet_id = "con-hub-vnet-id" # Shared Services: Hub VNet ID. 
}
