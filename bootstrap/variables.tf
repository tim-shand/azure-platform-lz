variable "subscription_id" {
  description = "Subscription ID of the dedicated IaC subscription."
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

variable "management_group_core_id" {
  description = "ID used for the naming of the top-level management group to be created."
  type        = string
  nullable    = false
  default     = "core"
}

variable "management_group_core_display_name" {
  description = "Display name of the top-level management group to be created."
  type        = string
  nullable    = false
  default     = "Core"
}

variable "backend_categories" {
  description = "Backend category objects, used to define the top-level IaC backend structure."
  type = map(object({
    name            = string # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
    enable_keyvault = bool   # Enable to create a Key Vault in this backend category Resource Group. 
  }))
}

variable "platform_stacks" {
  description = "Map of deployment objects listing the platform stack details."
  type = map(object({
    stack_name              = string
    backend_category        = string # Group deployments by backend category (platform, workloads). 
    subscription_identifier = string # Name part that is used in "contains" filter to resolve ID.
    create_environment      = bool   # Enable to create related environment in GitHub for stack.  
  }))
}

variable "workload_stacks" {
  description = "Map of deployment objects listing the workload stack details."
  type = map(object({
    stack_name              = string
    stack_category          = string # Group deployments by category (platform, workloads). 
    subscription_identifier = string # Name part that is used in "contains" filter to resolve ID.
  }))
}
