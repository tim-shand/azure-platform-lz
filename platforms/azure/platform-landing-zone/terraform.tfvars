# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# General
location = "newzealandnorth"
naming = {
  prefix      = "tjs"      # Short name of organization ("abc").
  service     = "plz"      # Service name used in the project ("iac", "mgt", "sec").
  project     = "platform" # Project name for related resources ("platform", "landingzone").
  environment = "prd"      # Environment for resources/project ("dev", "tst", "prd", "alz").
}

# Tags (assigned to all bootstrap resources).
tags = {
  Project     = "Platform-LZ" # Name of the project the resources are for.
  Environment = "prd"         # dev, tst, prd, alz
  Owner       = "CloudOps"    # Team responsible for the resources.
}

# Governance: Management Groups -----------------#
gov_management_group_list = {
  "core" = {
    display_name = "Core" # Top level Management Group.
  }
  "platform" = {
    display_name = "Platform"
    # Insert subscriptions here at runtime via pipeline.
  }
  "workloads" = {
    display_name = "Workloads"
  }
  "sandbox" = {
    display_name = "Sandbox"
  }
  "decom" = {
    display_name = "Decommissioned"
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
