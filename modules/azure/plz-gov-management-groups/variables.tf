#=================================================#
# Platform: Deploying Azure Platform Landing Zone.
#=================================================#

# General

variable "naming" {
  description = "A map of naming parameters to use with resources."
  type        = map(string)
  default     = {}
}

# Specific

variable "plz_management_groups" {
  description = "Map of management groups to create."
  type = map(object({ # Use object name as 'name'.
    mg_display_name = string
    subscription_ids = optional(list(string))
  }))
}

variable "subscription_ids_plz" {
  description = "List of subscription IDs for the Platform management group."
  type        = list(string)
}
