# Global: Map of global variables used across multiple deployment stacks. 
global = {
  naming = {                 # Map of name related variables (merge with "stack.naming"). 
    org_prefix       = "tjs" # Organisation abbreviated name. Example: "abc" (Azure Balloon Company).
    workload_project = "plz" # Workload project, overall category or additional grouping name. 
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

# Global Outputs (Shared Services): Mapping of key names used with global output value storage. 
# *** DO NOT MODIFY **** - This structure is relied on for accessing cross-subscription resources. 
global_outputs = {
  iac = {
    label                       = "iac"
    iac_service_principal_appid = "iac-service-principal-appid" # Pipeline Service Principal App ID.
    iac_service_principal_name  = "iac-service-principal-name"  # Pipeline Service Principal name.
  }
  subscriptions = {
    identity     = "sub-identity-id"     # Subscription ID for the Identity stack. 
    governance   = "sub-governance-id"   # Subscription ID for the Governance stack. 
    management   = "sub-management-id"   # Subscription ID for the Managementstack. 
    connectivity = "sub-connectivity-id" # Subscription ID for the Connectivity stack. 
  }
  governance = {
    label                = "governance"
    core_mg_id           = "gov-mg-core-id"           # Top-level Management Group ID. 
    core_mg_name         = "gov-mg-core-name"         # Top-level Management Group name. 
    platform_mg_id       = "gov-mg-platform-id"       # Platform Management Group ID. 
    platform_mg_name     = "gov-mg-platform-name"     # Platform Management Group name. 
    policy_diag_plz_name = "gov-policy-diag-plz-name" # Name of initiative for deploying platform diagnostics. 
    policy_managed_idn   = "gov-policy-deploy-mi-id"  # ID of the managed identity for deploying policy settings. 
  }
  management = {
    label                                  = "management"
    log_analytics_workspace_id             = "mgt-log-law-id"   # Log Analytics Workspace ID. 
    log_analytics_workspace_name           = "mgt-log-law-name" # Log Analytics Workspace name. 
    log_analytics_workspace_resource_group = "mgt-log-law-rg"   # Log Analytics Workspace resource group. 
    storage_account_id                     = "mgt-log-sa-id"    # Storage Account ID. 
    storage_account_name                   = "mgt-log-sa-name"  # Storage Account name. 
    storage_account_resource_group         = "mgt-log-sa-rg"    # Storage Account resource group. 
  }
  connectivity = {
    label                   = "connectivity"
    hub_vnet_id             = "con-hub-vnet-id"   # Hub VNet ID. 
    hub_vnet_name           = "con-hub-vnet-name" # Hub VNet name. 
    hub_vnet_resource_group = "con-hub-vnet-rg"   # Hub VNet resource group. 
    firewall_id             = "con-hub-afw-id"    # Azure Firewall ID. 
    firewall_name           = "con-hub-afw-name"  # Azure Firewall name. 
    firewall_resource_group = "con-hub-afw-rg"    # Azure Firewall resource group.
  }
}
