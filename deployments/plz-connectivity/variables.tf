variable "subscription_id_iac" {
  description = "Subscription ID of the dedicated IaC subscription."
  type        = string
  nullable    = false
}

variable "subscription_id" {
  description = "Subscription ID for the stack resources."
  type        = string
  nullable    = false
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

variable "global_outputs" {
  description = "Map of Shared Service key names, used to get IDs and names in data calls."
  type        = map(map(string))
}

variable "global_outputs_name" {
  description = "Name of global outputs shared service App Configuration created during bootstrap."
  type        = string
}

variable "global_outputs_rg" {
  description = "Map of global outputs shared service Resource Group for App Configuration created during bootstrap."
  type        = string
}

# CONNECTIVITY: General
# ------------------------------------------------------------- #

variable "vnet_hub_cidr" {
  description = "List of address spaces for hub VNet."
  type        = list(string)
  nullable    = false
}

variable "hub_bastion" {
  description = "Object describing the Bastion configuration."
  type = object({
    enabled = bool
    subnet  = list(string)
    sku     = string # Standard required for 'Native client support'. 
  })
}

variable "hub_firewall" {
  description = "Object describing the Firewall configuration."
  type = object({
    enabled    = bool
    subnet     = list(string)
    subnet_mgt = list(string)
    sku_name   = string
    sku_tier   = string
    policy_sku = string
  })
}

variable "hub_gateway" {
  description = "Object describing the VPN Gateway configuration."
  type = object({
    enabled = bool
    subnet  = list(string)
    type    = string
    sku     = string
  })
  validation {
    condition     = contains(["Vpn", "ExpressRoute"], var.hub_gateway.type)
    error_message = "One of 'Vpn' or 'ExpressRoute' must be provided."
  }
}

# CONNECTIVITY: Firewall Rules
# ------------------------------------------------------------- #

# variable "firewall_rules_default_application" {
#   description = "Map of objects containing firewall rules (application)."
#   type = map(object({
#     source_addresses = list(string)
#     target_fqdns     = list(string)
#     protocol = object({
#       port = string
#       type = string
#     })
#     })
#   )
# }

# variable "firewall_rules_default_network" {
#   description = "Map of objects containing firewall rules (network))."
#   type = map(object({
#     source_addresses      = list(string)
#     destination_ports     = list(string)
#     destination_addresses = optional(list(string)) # Either 'addresses' or 'fqdns' only. 
#     destination_fqdns     = optional(list(string))
#     protocols             = list(string)
#   }))
#   validation {
#     condition = alltrue([
#       for rule in values(var.firewall_rules_default_network) :
#       (
#         (try(rule.destination_addresses, null) != null ? 1 : 0) +
#         (try(rule.destination_fqdns, null) != null ? 1 : 0)
#       ) == 1
#     ])
#     error_message = "Each network firewall rule must define exactly one of destination_addresses or destination_fqdns."
#   }
# }

variable "firewall_policy_rule_collections" {
  description = "Firewall policy rule collections grouped by collection type."
  type = object({
    application = optional(map(object({
      priority = number
      action   = string
      rules = map(object({
        source_addresses = list(string)
        target_fqdns     = list(string)
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
