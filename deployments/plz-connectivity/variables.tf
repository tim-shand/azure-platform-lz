# GENERAL ----------------------------------------------------------- #

variable "terraform_version" {
  description = "Version of Terraform to pin for use in workflows."
  type = string
  default = ""
}

variable "global" {
  description = "Map of global variables used across multiple deployment stacks."
  type        = map(map(string))
  nullable    = false
  default     = {}
}

variable "stack" {
  description = "Map of stack specific variables for use within current deployment."
  type        = map(map(string))
  nullable    = false
  default     = {}
}

variable "subscription_id" {
  description = "Subscription ID for the stack deployment."
  type        = string
  nullable    = false
}

variable "subscription_id_iac" {
  description = "Subscription ID for the IaC backend deployment."
  type        = string
  nullable    = false
}

variable "remote_state_resource_group" {
  description = "Name of the Resource Groups that contains remote state backends."
  type = string
  default = ""
}

variable "remote_state_storage_account" {
  description = "Name of the Storage Account that contains remote state backends."
  type = string
  default = ""
}

variable "deployment_stacks" {
  description = "Map of objects defining the stacks for each deployment."
  type = map(object({
    stack_name              = string
    stack_code              = string
    subscription_identifier = string
    enable_github_env       = bool
  }))
}

# VIRTUAL NETWORK ------------------------------------------------------------- #

variable "ip_address_space" {
  description = "Map of hub and on-prem address spaces."
  type = map(string)
}

variable "hub_shared" {
  description = "Map of values to configure the hub shared subnet."
  type = object({
    name = string
    subnets = list(string)
  })
}

# FIREWALL ------------------------------------------------------------- #

variable "hub_firewall" {
  description = "Object of values to define the hub Azure Firewall configuration."
  type = object({
    enabled     = bool   # true/false to enable/disable service and associated resources.
    sku_name    = string # AZFW_VNet, AZFW_Hub
    sku_tier    = string # "Basic","Standard","Premium"
    subnets     = optional(list(string), [])
    features    = optional(map(bool), {})
  })
  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.hub_firewall.sku_name)
    error_message = "Invalid SKU name provided. Must be one of: AZFW_VNet or AZFW_Hub."
  }
  validation {
    condition     = contains(["Basic","Standard","Premium"], var.hub_firewall.sku_tier)
    error_message = "Invalid SKU tier provided. Must be one of: Basic, Standard, Premium."
  }
}

# BASTION ------------------------------------------------------------- #

variable "hub_bastion" {
  description = "Object of values to define the hub Bastion configuration."
  type = object({
    enabled     = bool   # true/false to enable/disable service and associated resources.
    sku_tier    = string # "Basic","Standard","Premium"
    subnets     = optional(list(string), [])
    features    = optional(map(bool), {})
  })
  validation {
    condition     = contains(["Developer","Basic","Standard","Premium"], var.hub_bastion.sku_tier)
    error_message = "Invalid SKU provided. Must be one of: Developer, Basic, Standard, Premium."
  }
}

# VPN GATEWAY ------------------------------------------------------------- #

variable "hub_vpn" {
  description = "Object of values to define the hub VPN configuration."
  type = object({
    enabled     = bool   # true/false to enable/disable service and associated resources.
    sku_tier    = string # "Basic","Standard","Premium"
    vpn_type    = string # "RouteBased", "PolicyBased".
    subnets     = optional(list(string), [])
    local_address_spaces = list(string)         # Address spaces for on-prem networks.
    connection_type       = string
    connection_protocol   = string
    ipsec_policy = optional(object({
      ike_encryption   = optional(string, "AES256")
      ike_integrity    = optional(string, "SHA256")
      dh_group         = optional(string, "DHGroup14")
      ipsec_encryption = optional(string, "AES256")
      ipsec_integrity  = optional(string, "SHA256")
      pfs_group        = optional(string, "PFS14")
      sa_lifetime      = optional(number, 27000)
      sa_datasize      = optional(number, 102400000)
    }), {
      ike_encryption   = "AES256"
      ike_integrity    = "SHA256"
      dh_group         = "DHGroup14"
      ipsec_encryption = "AES256"
      ipsec_integrity  = "SHA256"
      pfs_group        = "PFS14"
      sa_lifetime      = 27000
      sa_datasize      = 102400000
    })
    features    = optional(map(bool), {})
  })
  validation {
    condition     = contains(["RouteBased", "PolicyBased"], var.hub_vpn.vpn_type)
    error_message = "Invalid SKU provided. Must be one of: RouteBased, PolicyBased."
  }
    validation {
    condition     = contains(["Basic", "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "HighPerformance", "UltraPerformance"], var.hub_vpn.sku_tier)
    error_message = "VPN Gateway SKU must be Basic, VpnGw1-VpnGw3, VpnGw1AZ-VpnGw3AZ, HighPerformance, or UltraPerformance."
  }
  validation {
    condition     = contains(["AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES192", "GCMAES256"], var.hub_vpn.ipsec_policy.ike_encryption)
    error_message = "IKE encryption must be AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, or GCMAES256."
  }
  validation {
    condition     = contains(["MD5", "SHA1", "SHA256", "SHA384", "GCMAES128", "GCMAES192", "GCMAES256"], var.hub_vpn.ipsec_policy.ike_integrity)
    error_message = "IKE integrity must be MD5, SHA1, SHA256, SHA384, GCMAES128, GCMAES192, or GCMAES256."
  }
  validation {
    condition     = contains(["DHGroup1", "DHGroup2", "DHGroup14", "DHGroup24", "DHGroup2048", "ECP256", "ECP384", "None"], var.hub_vpn.ipsec_policy.dh_group)
    error_message = "DH group must be DHGroup1, DHGroup2, DHGroup14, DHGroup24, DHGroup2048, ECP256, ECP384, or None."
  }
  validation {
    condition     = contains(["AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES192", "GCMAES256", "None"], var.hub_vpn.ipsec_policy.ipsec_encryption)
    error_message = "IPSec encryption must be AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None."
  }
  validation {
    condition     = contains(["MD5", "SHA1", "SHA256", "GCMAES128", "GCMAES192", "GCMAES256"], var.hub_vpn.ipsec_policy.ipsec_integrity)
    error_message = "IPSec integrity must be MD5, SHA1, SHA256, GCMAES128, GCMAES192, or GCMAES256."
  }
  validation {
    condition     = contains(["ECP256", "ECP384", "PFS1", "PFS2", "PFS14", "PFS24", "PFS2048", "PFSMM", "None"], var.hub_vpn.ipsec_policy.pfs_group)
    error_message = "PFS group must be ECP256, ECP384, PFS1, PFS2, PFS14, PFS24, PFS2048, PFSMM, or None."
  }
}

variable "vpn_public_ip" {
  description = "The string value of public IP from the local (on-prem) VPN device."
  sensitive   = false
  type        = string
}

variable "vpn_local_psk" {
  description = "The string value of the Pre-Shared Key obtained from local (on-prem) VPN device."
  sensitive   = true
  type        = string
}


# FIREWALL RULES ------------------------------------------------------------- #

variable "firewall_policy_rule_collections" {
  description = "Firewall policy rule collections grouped by collection type."
  type = object({
    application = optional(map(object({
      priority = number
      action   = string
      rules = map(object({
        source_addresses  = list(string)
        destination_fqdns = list(string)
        protocols = list(object({
          type = string
          port = number
        }))
      }))
    })), {})
    network = optional(map(object({
      priority = number
      action   = string
      rules = map(object({
        source_addresses      = list(string)
        destination_ports     = list(string)
        protocols             = list(string)
        destination_addresses = optional(list(string))
        destination_fqdns     = optional(list(string))
      }))
    })), {})
  })

  validation {
    condition = alltrue(flatten([
      for collection in values(var.firewall_policy_rule_collections.network) : [
        for rule in values(collection.rules) :
        (
          (try(rule.destination_addresses, null) != null ? 1 : 0) +
          (try(rule.destination_fqdns, null) != null ? 1 : 0)
        ) == 1
      ]
    ]))
    error_message = "Each network rule must define exactly one of destination_addresses or destination_fqdns."
  }

  validation {
    condition = alltrue(flatten([
      for collection in values(var.firewall_policy_rule_collections.application) : [
        contains(["Allow", "Deny"], collection.action)
      ]
    ]))
    error_message = "Application rule collection action must be Allow or Deny."
  }

  validation {
    condition = alltrue(flatten([
      for collection in values(var.firewall_policy_rule_collections.network) : [
        contains(["Allow", "Deny"], collection.action)
      ]
    ]))
    error_message = "Network rule collection action must be Allow or Deny."
  }
}
