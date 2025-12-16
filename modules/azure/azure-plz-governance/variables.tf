variable "gov_management_group_root" {
  description = "Name of the top-level Management Group (root)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.resource_name)) # Only allow alpha-numeric with dashes.
    error_message = "Variable can only contain letters, numbers, and dashes (-). No spaces or other symbols are allowed."
  }
}

variable "gov_management_group_list" {
  description = "Map of Management Group configuration to deploy."
  type = map(object({ # Use object variable name as management group 'name'.
    display_name      = string
    subscription_list = optional(list(strings))
  }))
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.resource_name)) # Only allow alpha-numeric with dashes.
    error_message = "Variable can only contain letters, numbers, and dashes (-). No spaces or other symbols are allowed."
  }
}
