# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                       # Map of name related variables (merge with "global.naming")
    workload_code = "con"          # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Connectivity" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                          # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Owner      = "CloudOpsTeam"     # Name of the team that owns the project. 
    CostCenter = "Platform"         # Useful for grouping resources for billing/financial accountability.
    Deployment = "plz-connectivity" # Workload/project name, used to group and identify related resources.
  }
}

# VNet: Hub
vnet_hub_cidr = ["10.50.0.0/22"] # /22 = 4x /24
vnet_hub_subnets = {
  firewall = {
    enabled                         = true
    address_prefixes                = ["10.50.0.0/24"] # Address space used for Azure Firewall or other NVA.
    default_outbound_access_enabled = false            # Enable default outbound access to the internet for the subnet.
  }
  gateway = {
    enabled                         = true
    address_prefixes                = ["10.50.1.0/24"] # Address space used for VPN Gateway (if enabled).
    default_outbound_access_enabled = false            # Enable default outbound access to the internet for the subnet.
  }
  management = {
    enabled                         = true
    address_prefixes                = ["10.50.2.0/24"] # Address space used for Management via peered VM networks.
    default_outbound_access_enabled = false            # Enable default outbound access to the internet for the subnet.
  }
  bastion = {
    enabled                         = true
    address_prefixes                = ["10.50.3.0/24"] # Address space used for Azure Bastion for remote access.
    default_outbound_access_enabled = false            # Enable default outbound access to the internet for the subnet.
  }
}
