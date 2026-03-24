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

# Connectivity Services
hub_firewall = {
  enabled    = true
  subnet     = ["10.50.0.0/24"]
  subnet_mgt = ["10.50.1.0/24"]
  sku_name   = "AZFW_VNet" # AZFW_Hub
  sku_tier   = "Basic"     # Standard, Premium
  policy_sku = "Basic"     # Standard, Premium
}

hub_bastion = {
  enabled = true
  subnet  = ["10.50.2.0/24"]
  sku     = "Basic" # Standard required for 'Native client support'.
}

hub_gateway = {
  enabled = true
  subnet  = ["10.50.3.0/24"]
  sku     = "Basic"
  type    = "Vpn" # ExpressRoute
}

# Firewall Rules --------------------------------------#

firewall_policy_rule_collections = {
  # Application Rules
  application = {
    "plz-default-application" = {
      priority = 100
      action   = "Allow"
      rules = {
        "global-allowed-urls" = {
          source_addresses  = ["*"]
          destination_fqdns = ["*.google.com", "*.cloudflare.com", "*.microsoft.com", "pool.ntp.org"]
          protocols = [
            {
              type = "Https"
              port = 443
            }
          ]
        }
      }
    }
  }
  # Network Rules
  network = {
    "plz-default-network" = {
      priority = 200
      action   = "Allow"
      rules = {
        "global-allowed-network-dns" = {
          source_addresses      = ["*"]
          destination_ports     = ["53"]
          destination_addresses = ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
          protocols             = ["TCP", "UDP"]
        }
        "global-allowed-network-ntp" = {
          source_addresses  = ["*"]
          destination_ports = ["123"]
          destination_fqdns = ["pool.ntp.org", "time.cloudflare.com", "time.google.com"]
          protocols         = ["UDP"]
        }
      }
    }
  }
}
