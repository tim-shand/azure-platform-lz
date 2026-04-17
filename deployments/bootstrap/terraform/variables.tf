# GLOBAL ----------------------------------------------------------- #

variable "terraform_version" {
  description = "Version of Terraform to pin for use in workflows."
  type = string
  nullable = false
}

variable "global" {
  description = "Map of global variables used across multiple deployment stacks."
  type        = map(map(string))
  nullable    = false
}

variable "stack" {
  description = "Map of stack specific variables for use within current deployment."
  type        = map(map(string))
  default     = {}
}

variable "subscription_id" {
  description = "Subscription ID for the stack deployment."
  type        = string
  nullable    = false
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

# # Subscription IDs for deployment stacks.
# variable "platform_subscription_identifiers" {
#   description = "Object containing string values unique to each stack subscription. Used ONCE to get ID values using data call."
#   type = object({
#     mgt = string
#     gov = string
#     con = string
#   })
#   nullable = false
#   validation {
#     condition     = length(trimspace(var.platform_subscription_identifiers.mgt)) > 0
#     error_message = "The subscription display name must not be empty."
#   }
#   validation {
#     condition     = length(trimspace(var.platform_subscription_identifiers.gov)) > 0
#     error_message = "The subscription display name must not be empty."
#   }
#   validation {
#     condition     = length(trimspace(var.platform_subscription_identifiers.con)) > 0
#     error_message = "The subscription display name must not be empty."
#   }
# }

# # Managment Group: Core (Top-Level)
# variable "management_group_core" {
#   description = "Map defining the core management group used as the top-level MG."
#   type        = map(string)
#   nullable    = false
# }

