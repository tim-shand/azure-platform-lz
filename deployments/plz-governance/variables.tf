# General ----------------------------------------------------------|
variable "global" {
  description = "Map of global variable configuration values."
  type        = map(map(string))
}

variable "naming" {
  description = "Map of deployment naming parameters to use with resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "subscription_id" {
  description = "Subscription ID for the target changes. Provided by workflow variable or terminal input."
  type        = string
  validation {                                        # Functions to verify if the string can be parsed as a UUID, catch invalid or mising characters. 
    condition     = length(var.subscription_id) == 36 #&& can(uuid(var.subscription_id)) # Checks for the typical length of a GUID.
    error_message = "The subscription ID must be a valid 36-character GUID."
  }
}

# Management Groups ----------------------------------------------------------|
# variable "management_group_root" {
#   description = "Name ID to use for the top-level (root) Management Group."
#   type        = string
#   validation {
#     condition     = can(regex("^[a-zA-Z0-9-]+$", var.management_group_root)) # Only allow alpha-numeric with dashes.
#     error_message = "Must be a string of alpha-numeric characters (can contain dashes), between 3 and 36 in length."
#   }
# }

variable "management_group_root" {
  description = "Map of root level Management Group details."
  type = map(object({
    display_name           = string                 # Display name for root MG. 
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    policy_initiatives     = optional(list(string)) # Assign Policy Initiatives directly to MGs. 
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_group_root : length(details.display_name) >= 3
    ])
    error_message = "The root Management Group must contain three or more characters."
  }
}

variable "management_groups_level1" {
  description = "Map of first level Management Group objects, nested under the root Manangement Group."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    policy_initiatives     = optional(list(string)) # Assign Policy Initiatives directly to MGs. 
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level1 : length(details.display_name) > 1
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 1 Management Groups."
  }
}

variable "management_groups_level2" {
  description = "Map of second level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
    policy_initiatives     = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level2 : length(details.display_name) > 1 && length(details.parent_mg_name) > 1
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 2 Management Groups."
  }
}

variable "management_groups_level3" {
  description = "Map of third level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
    policy_initiatives     = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level3 : length(details.display_name) > 1 && length(details.parent_mg_name) > 1
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 3 Management Groups."
  }
}

variable "management_groups_level4" {
  description = "Map of fourth level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
    policy_initiatives     = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level4 : length(details.display_name) > 1 && length(details.parent_mg_name) > 1
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 4 Management Groups."
  }
}

variable "management_groups_level5" {
  description = "Map of fifth level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
    policy_initiatives     = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level5 : length(details.display_name) > 1 && length(details.parent_mg_name) > 1
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 5 Management Groups."
  }
}

# Policy Assignment -----------------#
variable "policy_initiatives_builtin" {
  description = "Set of display name for built-in policy initiatives to assign at root management group."
  type        = set(string)
  default     = []
  nullable    = true
}

variable "policy_initiatives_builtin_enforce" {
  description = "Enable to enforce the built-in policy initiative."
  type        = bool
  default     = false
}

variable "policy_initiatives_builtin_enable" {
  description = "Enable assignment of the built-in policy initiative (turns it on/off)."
  type        = bool
  default     = true
}

variable "policy_initiatives" {
  description = "Policy Initiatives and member Definition names."
  type        = map(list(string))
}

variable "policy_allowed_locations" {
  description = "List of allowed locations for resources in string format."
  type        = list(string)
}

variable "policy_required_tags" {
  description = "List of required tags to be assigned to resources in string format."
  type        = list(string)
}

variable "policy_allowed_vm_skus" {
  description = "List of allowed SKUs when deploying VMs."
  type        = list(string)
}
