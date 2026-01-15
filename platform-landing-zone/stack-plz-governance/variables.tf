# General  -----------------#

variable "subscription_id" {
  description = "Subscription ID for the target changes. Provided by workflow variable."
  type        = string
}

variable "global" {
  description = "Map of static global variables (location etc) used for all deployments."
  type        = map(string)
  nullable    = false
}

variable "naming" {
  description = "A map of naming values to use with resources."
  type        = map(string)
  nullable    = false
}

variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
}

variable "stack_code" {
  description = "Short code used for stack resource naming."
  type        = string
}

variable "stack_name" {
  description = "Full name used for stack resource naming."
  type        = string
}

# Governance: Management Groups -----------------#

variable "management_group_root" {
  description = "Name of the top-level Management Group (root)."
  type        = string
  default     = "Core"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.management_group_root)) # Only allow alpha-numeric with dashes.
    error_message = "Management Group IDs can only contain letters, numbers, and dashes (-). No spaces or other symbols are allowed."
  }
}

variable "management_group_list" {
  description = "Map of Management Group configuration to deploy."
  type = map(object({ # Use object variable name as management group 'name'.
    display_name            = string
    subscription_identifier = optional(string)       # Used to identify existing subscriptions to add to the management group.
    subscription_list       = optional(list(string)) # Provide raw subscription IDs if not match 'subcription_identifier'. 
  }))
  validation {
    condition = alltrue([
      for key in keys(var.management_group_list) : # Ensure that provided Management Group IDs are valid.
      can(regex("^[a-zA-Z0-9-]+$", key))           # Check each object key to ensure it fits the regex requirements. 
    ])
    error_message = "Management Group IDs can only contain letters, numbers, and dashes (-). No spaces or other symbols are allowed."
  }
}

# Governance: Policy Parameters -----------------#

variable "policy_builtin_initiatives" {
  description = "Set of display name for built-in policy initiatives to assign."
  type        = set(string)
  default     = []
  nullable    = true
}

variable "policy_custom_allowed_locations" {
  description = "Object of policy settings that determine values and effect for allowed locations."
  type = object({
    effect    = string       # Audit, Deny, Disabled
    locations = list(string) # List of allowed locations allowed when deploying resources.
  })
  default = {
    effect    = "audit"
    locations = ["newzealandnorth"]
  }
  validation {
    condition     = length(var.policy_custom_allowed_locations.locations) >= 1
    error_message = "At least one allowed location must be provided."
  }
}

variable "policy_custom_required_tags" {
  description = "Object of policy settings that determine values and effect for required tags."
  type = object({
    effect = string       # Audit, Deny, Disabled
    tags   = list(string) # List of required tags when deploying resources.
  })
  default = {
    effect = "audit"
    tags   = ["Owner", "Environment", "Project"]
  }
  validation {
    condition     = length(var.policy_custom_required_tags.tags) >= 1
    error_message = "At least three tag names MUST be provided."
  }
}

variable "policy_custom_def_path" {
  description = "Local directory path containing custom policy definitions in JSON format."
  type        = string
  default     = "./policy_definitions"
}
