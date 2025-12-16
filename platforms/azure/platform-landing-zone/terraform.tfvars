# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# General
location = "newzealandnorth"
naming = {
  org     = "tjs"      # Short name of organization (abc).
  service = "plz"      # Service name used in the project (iac, mgt, sec).
  project = "platform" # Project name for related resources (platform, landingzone).
}

# Tags (assigned to all bootstrap resources).
tags = {
  Project     = "PlatformLandingZone" # Name of the project the resources are for.
  Environment = "prd"                 # dev, tst, prd
  Owner       = "CloudOps"            # Team responsible for the resources.
}

# Governance: Management Groups -----------------#
gov_management_group_root = "Core" # Top level Management Group name.
gov_management_group_list = {
  platform = {
    display_name           = "Platform" # Cosmetic name for Management Group.
    subcription_identifier = "mgt"      # Used to identify existing subscriptions to add to the Management Group. 
  }
  workloads = {
    display_name           = "Workloads"
    subcription_identifier = "app"
  }
  sandbox = {
    display_name           = "Sandbox"
    subcription_identifier = "dev"
  }
  decom = {
    display_name = "Decommission"
  }
}

# Connectivity: Network (Hub) -----------------#
hub_vnet_space = "10.50.0.0/22" # Allows 4x /24 subnets.
hub_subnets = {
  "AzureManagementSubnet" = {
    name                    = "mgt"
    address                 = ["10.50.0.0/24"]
    default_outbound_access = true
  }
  "AzureFirewallSubnet" = {
    name                    = "fwl"
    address                 = ["10.50.1.0/26"]
    default_outbound_access = true
  }
  "AzureGatewaySubnet" = {
    name                    = "gwy"
    address                 = ["10.50.2.0/24"]
    default_outbound_access = false
  }
  "AzureBastionSubnet" = {
    name                    = "bas"
    address                 = ["10.50.3.0/26"]
    default_outbound_access = false
  }
}

# Logging: Monitoring & Diagnostics -----------------#
logging_law = {
  "sku"            = "PerGB2018"
  "retention_days" = "30"
}
