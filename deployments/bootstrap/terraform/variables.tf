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

variable "custom_role_enable" {
  description = "Boolean to control whether custom role for deployment is created and assigned."
  type        = bool
  default     = true
}

variable "management_group_core" {
  description = "Map of core Management Group details."
  type = map(object({
    display_name             = string
    parent_mg_name           = optional(string)       # NOT Required.
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values. 
    #policy_initiatives       = optional(list(string)) # Assign Policy Initiatives directly to MGs. 
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_group_core : length(details.display_name) >= 3
    ])
    error_message = "Display name is required for the core Management Group."
  }
}
