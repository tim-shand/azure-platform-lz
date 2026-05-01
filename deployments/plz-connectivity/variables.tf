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

variable "hub_services" {
  description = "Map of hub services and their features/configuration."
  type = map(any)
}

# FIREWALL ------------------------------------------------------------- #

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
