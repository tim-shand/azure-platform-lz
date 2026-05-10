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

# FIREWALL ------------------------------------------------------------- #

variable "hub_firewall" {
  description = "Object of values to define the hub Azure Firewall configuration."
  type = object({
    enabled     = bool   # true/false to enable/disable service and associated resources.
    sku_name    = string # AZFW_VNet, AZFW_Hub
    sku_tier    = string # "Basic","Standard","Premium"
    policy_sku  = string # "Basic","Standard","Premium"
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
  validation {
    condition     = contains(["Basic","Standard","Premium"], var.hub_firewall.policy_sku)
    error_message = "Invalid firewall policy SKU provided. Must be one of: Basic, Standard, Premium."
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
    local_public_ip      = string               # Passed via GitHub Variables at runtime.
    local_address_spaces = list(string)         # Address spaces for on-prem networks.
    features    = optional(map(bool), {})
  })
  validation {
    condition     = contains(["Basic","Standard","HighPerformance","VpnGw1","VpnGw2","VpnGw1AZ","VpnGw2AZ"], var.hub_vpn.sku_tier)
    error_message = "Invalid SKU provided. Must be one of: Basic, Standard, HighPerformance, VpnGw1, VpnGw2, VpnGw1AZ, VpnGw2AZ."
  }
  validation {
    condition     = contains(["RouteBased", "PolicyBased"], var.hub_vpn.vpn_type)
    error_message = "Invalid SKU provided. Must be one of: RouteBased, PolicyBased."
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

# DNS RESOLVER ------------------------------------------------------------- #

variable "hub_dns" {
  description = "value"
  type = object ({
    enabled     = bool   # true/false to enable/disable service and associated resources.
    subnets     = optional(list(string), [])
    features    = optional(map(bool), {})
  })
}


# variable "firewall_policy_rule_collections" {
#   description = "Firewall policy rule collections grouped by collection type."
#   type = object({
#     application = optional(map(object({
#       priority = number
#       action   = string
#       rules = map(object({
#         source_addresses  = list(string)
#         destination_fqdns = list(string)
#         protocols = list(object({
#           type = string
#           port = number
#         }))
#       }))
#     })), {})

#     network = optional(map(object({
#       priority = number
#       action   = string
#       rules = map(object({
#         source_addresses      = list(string)
#         destination_ports     = list(string)
#         protocols             = list(string)
#         destination_addresses = optional(list(string))
#         destination_fqdns     = optional(list(string))
#       }))
#     })), {})
#   })

#   validation {
#     condition = alltrue(flatten([
#       for collection in values(var.firewall_policy_rule_collections.network) : [
#         for rule in values(collection.rules) :
#         (
#           (try(rule.destination_addresses, null) != null ? 1 : 0) +
#           (try(rule.destination_fqdns, null) != null ? 1 : 0)
#         ) == 1
#       ]
#     ]))
#     error_message = "Each network rule must define exactly one of destination_addresses or destination_fqdns."
#   }

#   validation {
#     condition = alltrue(flatten([
#       for collection in values(var.firewall_policy_rule_collections.application) : [
#         contains(["Allow", "Deny"], collection.action)
#       ]
#     ]))
#     error_message = "Application rule collection action must be Allow or Deny."
#   }

#   validation {
#     condition = alltrue(flatten([
#       for collection in values(var.firewall_policy_rule_collections.network) : [
#         contains(["Allow", "Deny"], collection.action)
#       ]
#     ]))
#     error_message = "Network rule collection action must be Allow or Deny."
#   }
# }
