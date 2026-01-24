# General ----------------------------------------------------------|
variable "global" {
  description = "Map of global variable configuration values."
  type        = map(map(string))
}

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

variable "management_group_root" {
  description = "Map of root Management Group object (top-level)."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_group_root : length(details.display_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 1 Management Groups."
  }
}

variable "management_groups_level1" {
  description = "Map of first level Management Group objects, nested under the root Manangement Group."
  type = map(object({
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level1 : length(details.display_name) >= 3
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
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
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
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
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
    display_name           = string
    subscription_id_filter = optional(list(string)) # Optional list of subscription prefixes (3 segments). 
    parent_mg_name         = string
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level5 : length(details.display_name) >= 3 && length(details.parent_mg_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 5 Management Groups."
  }
}
