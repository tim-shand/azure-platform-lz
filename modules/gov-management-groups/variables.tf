# General ----------------------------------------------------------|
variable "naming_prefix" {
  description = "String value used for resource naming."
  type        = string
}

# Subscriptions ----------------------------------------------------------|
variable "subscriptions" {
  description = "List of all subscriptions available in tenant."
  type = list(object({
    display_name          = string
    id                    = string
    location_placement_id = string
    quota_id              = string
    spending_limit        = string
    state                 = string
    subscription_id       = string
    tags                  = map(string)
    tenant_id             = string
  }))
}

variable "management_group_core" {
  description = "Name of core Management Group object (top-level)."
  type        = string
}

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

variable "management_groups_level4" {
  description = "Map of fourth level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name             = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.
    parent_mg_name           = string
    policy_initiatives       = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level4 : length(details.display_name) >= 3 && length(details.parent_mg_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 4 Management Groups."
  }
}

variable "management_groups_level5" {
  description = "Map of fifth level Management Group objects, nested under defined parent Management Group."
  type = map(object({
    display_name             = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.
    parent_mg_name           = string
    policy_initiatives       = optional(list(string)) # Assign Policy Initiatives directly to MGs.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level5 : length(details.display_name) >= 3 && length(details.parent_mg_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 5 Management Groups."
  }
}
