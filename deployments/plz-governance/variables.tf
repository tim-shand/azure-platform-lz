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

variable "shared_services_name" {
  description = "Name of shared service App Configuration created during bootstrap."
  type        = string
}

variable "shared_services_rg" {
  description = "Map of shared service Resource Group for App Configuration created during bootstrap."
  type        = string
}

variable "shared_services" {
  description = "Map of Shared Service key names, used to get IDs and names in data calls."
  type        = map(string)
}

# GOVERNANCE: Management Groups
# ------------------------------------------------------------- #

variable "management_groups_level1" {
  description = "Map of first level Management Group objects, nested under the core Manangement Group."
  type = map(object({
    display_name             = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.  
    policy_initiatives       = optional(list(string)) # Assign Policy Initiatives directly to MGs. 
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level1 : length(details.display_name) >= 3
    ])
    error_message = "Display name is required for all Level 1 Management Groups."
  }
}

variable "management_groups_level2" {
  description = "Map of second level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name             = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.  
    parent_mg_name           = string
    policy_initiatives       = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level2 : length(details.display_name) >= 3 && length(details.parent_mg_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 2 Management Groups."
  }
}

variable "management_groups_level3" {
  description = "Map of third level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name             = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.
    parent_mg_name           = string
    policy_initiatives       = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level3 : length(details.display_name) >= 3 && length(details.parent_mg_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 3 Management Groups."
  }
}

variable "policy_initiatives_builtin" {
  description = "Map of objects containing built-in policy initiatives and their configuration settings."
  type = map(object({
    definition_id    = string # ID of the initiative (4f5b1359-4f8e-4d7c-9733-ea47fcde891e). 
    assignment_mg_id = string # Management Group ID to assign the initiative to. 
    enabled          = bool   # [true/false]: Toggle assignment.  
    enforce          = bool   # [true/false]: Toggle enforcement of policy initiative. 
  }))
}

# GOVERNANCE: Policy and Initiatives (Built-In)
# ------------------------------------------------------------- #

variable "policy_initiatives" {
  description = "Policy Initiatives and member Definition names."
  type        = map(list(string))
}

variable "policy_var_allowed_locations" {
  description = "List of allowed locations for resources in string format."
  type        = list(string)
}

variable "policy_var_required_tags" {
  description = "List of required tags to be assigned to resources in string format."
  type        = list(string)
}

variable "policy_var_allowed_vm_skus" {
  description = "List of allowed SKUs when deploying VMs."
  type        = list(string)
}
