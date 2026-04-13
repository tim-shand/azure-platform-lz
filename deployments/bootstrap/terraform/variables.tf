# GENERAL ----------------------------------------------------------- #

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

# STACK ------------------------------------------------------------ #

variable "terraform_version" {
  description = "Terraform version to use with workflows. Added to GitHub variables."
  type        = string
  nullable    = false
}

# Subscription IDs for deployment stacks.
variable "platform_subscription_identifiers" {
  description = "Object containing string values unique to each stack subscription. Used ONCE to get ID values using data call."
  type = object({
    mgt = string
    gov = string
    con = string
  })
  nullable = false
  validation {
    condition     = length(trimspace(var.platform_subscription_identifiers.mgt)) > 0
    error_message = "The subscription display name must not be empty."
  }
  validation {
    condition     = length(trimspace(var.platform_subscription_identifiers.gov)) > 0
    error_message = "The subscription display name must not be empty."
  }
  validation {
    condition     = length(trimspace(var.platform_subscription_identifiers.con)) > 0
    error_message = "The subscription display name must not be empty."
  }
}

# Managment Group: Core (Top-Level)
variable "management_group_core" {
  description = "Map defining the core management group used as the top-level MG."
  type        = map(string)
  nullable    = false
}
