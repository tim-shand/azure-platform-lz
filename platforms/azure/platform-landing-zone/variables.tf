#=================================================#
# Platform LZ: Variables
#=================================================#

# General  -----------------#
variable "subscription_id" {
  description = "Subscription ID for the target changes."
  type        = string
}
variable "location" {
  description = "Azure region to deploy resources into."
  type        = string
}
variable "naming" {
  description = "A map of naming parameters to use with resources."
  type        = map(string)
  default     = {}
}
variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default     = {}
}

# Governance: Management Groups -----------------#
variable "plz_management_groups" {
  description = "Map of management groups to create."
  type = map(object({ # Use object name as 'name'.
    mg_display_name = string
    subscription_ids = optional(list(string))
  }))
}
variable "subscription_ids_plz" {
  description = "List of subscription IDs for the 'Platform' management group, passed in via GH workflow."
  type = list(string)
}

# Connectivity: Network (Hub) -----------------#
variable "hub_vnet_space" {
  description = "IP address space for Hub vNet."
  type = string
}
variable "hub_subnets" {
  description = "Map of hub vNet subnet addresses."
  type = map(object({ # Use object name as 'name'.
    address = list(string)
  }))
}
