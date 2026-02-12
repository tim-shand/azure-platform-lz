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

variable "global_outputs" {
  description = "Map of Shared Service key names, used to get IDs and names in data calls."
  type        = map(string)
}

variable "global_outputs_name" {
  description = "Name of global outputs shared service App Configuration created during bootstrap."
  type        = string
}

variable "global_outputs_rg" {
  description = "Map of global outputs shared service Resource Group for App Configuration created during bootstrap."
  type        = string
}

# IDENTITY: Entra ID Groups
# ------------------------------------------------------------- #

variable "entra_groups_admins_prefix" {
  description = "Prefix value to append to administrator group naming format."
  type        = string
  default     = "GRP_ADM_"
}

variable "entra_groups_users_prefix" {
  description = "Prefix value to append to user access group naming format."
  type        = string
  default     = "GRP_USR_"
}

variable "entra_groups_admins" {
  description = "Map of objects defining the base groups for privilaged administrator roles."
  type = map(object({
    Description = string
    Active      = bool
  }))
}

variable "entra_groups_users" {
  description = "Map of objects defining the base groups for standard user access/team roles."
  type = map(object({
    Description = string
    Active      = bool
  }))
}

# ------------------------------------------------------------- #
