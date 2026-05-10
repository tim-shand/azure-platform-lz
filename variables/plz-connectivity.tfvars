# GENERAL ---------------------------------------------------- #

# Stack: Map of stack specific variables for use within current deployment. 
stack = {
  naming = {                     # Map of name related variables (merge with "global.naming")
    workload_code = "con"        # Short code for deployment stack. Can be used in naming methods. 
    workload_name = "Connectivity" # Workload name for deployment stack. Can be used in naming methods. 
  }
  tags = {                        # Tags to be merged with "global.tags" from "global.tfvars" file. 
    Owner      = "CloudOpsTeam"   # Name of the team that owns the project. 
    CostCenter = "Platform"       # Useful for grouping resources for billing/financial accountability.
    Deployment = "plz-connectivity" # Workload/project name, used to group and identify related resources.
  }
}

# VIRTUAL NETWORK (HUB) ---------------------------------------------------- #

# Provide address spaces for the hub and on-prem networks.
ip_address_space = {
    hub     = "10.200.0.0/16"
    onprem  = "10.0.0.0/16"
}

# Empty at connectivity stack deploy time.
# Populated when spoke VNets are created during workload vending.
#spoke_peerings = {}

# HUB SERVICES ---------------------------------------------------- #

# Configure settings for hub services.

hub_firewall = {
    enabled     = true              # true/false to enable/disable service and associated resources.
    sku_name    = "AZFW_VNet"       # One of: AZFW_VNet (hub-spoke) or AZFW_Hub (virtual WAN).
    sku_tier    = "Basic"           # "Basic","Standard","Premium"
    policy_sku  = "Basic"           # One of: Basic, Standard, Premium.
    subnets     = [
        "10.200.0.0/24", # Firewall
        "10.200.1.0/24"  # Firewall Management
    ]
}

hub_bastion = {
    enabled     = true          # true/false to enable/disable service and associated resources.
    sku_tier    = "Basic"       # "Developer","Basic","Standard","Premium"
    subnets     = [
        "10.200.2.0/24"
    ]
    features = {
        copy_paste_enabled          = true
        # Below only supported when SKU is Premium. Automatically set to "false" during deployment if "sku_tier" not suitable.
        file_copy_enabled           = true
        ip_connect_enabled          = true
        kerberos_enabled            = false
        shareable_link_enabled      = false
        tunneling_enabled           = true # Required for SFTP from on-prem via Bastion host.
        # Below only supported when SKU is Premium. Automatically set to "false" during deployment if "sku_tier" not suitable.
        session_recording_enabled   = false
    }
}

hub_vpn = {
    enabled         = true          # true/false to enable/disable service and associated resources.
    vpn_type        = "RouteBased"  # Required for IKEv2 and OPNsense compatibility (on-prem).
    sku_tier        = "Basic"       # "Basic","Standard","HighPerformance","VpnGw1"-"VpnGw5", "VpnGw1AZ"-"VpnGw5AZ".
    subnets         = [
        "10.200.3.0/24"
    ]
    local_address_spaces = ["10.0.0.0/16"]  # Address spaces for on-prem networks.
    connection_type         = "IPsec"
    connection_protocol     = "IKEv2"
    ipsec_policy = {
        ike_encryption   = "AES256"
        ike_integrity    = "SHA256"
        dh_group         = "DHGroup14"
        ipsec_encryption = "AES256"
        ipsec_integrity  = "SHA256"
        pfs_group        = "PFS14"
        sa_lifetime      = 27000
        sa_datasize      = 102400000
    }
    features = {
        active_active   = false         # Requires a HighPerformance or an UltraPerformance SKU.
        bgp_enabled     = false         # Requires "Standard" or higher SKU.
    }
}

# ============================================================== #
#
# Firewall Rules ---------------------------------------#
#
# ============================================================== #

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
              type = "Http"
              port = 80
            },
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