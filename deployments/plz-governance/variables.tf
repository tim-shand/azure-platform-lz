# GENERAL ----------------------------------------------------------- #

variable "terraform_version" {
  description = "Version of Terraform to pin for use in workflows."
  type = string
  default = ""
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

variable "subscription_id" {
  description = "Subscription ID for the stack deployment."
  type        = string
  nullable    = false
}

variable "subscription_id_iac" {
  description = "Subscription ID for the IaC backend deployment."
  type        = string
  nullable    = false
}

variable "remote_state_resource_group" {
  description = "Name of the Resource Groups that contains remote state backends."
  type = string
  default = ""
}

variable "remote_state_storage_account" {
  description = "Name of the Storage Account that contains remote state backends."
  type = string
  default = ""
}

variable "deployment_stacks" {
  description = "Map of objects defining the stacks for each deployment."
  type = map(object({
    stack_name              = string
    stack_code              = string
    subscription_identifier = string
    enable_github_env       = bool
  }))
}

# MANAGEMENT GROUPS ------------------------------------------------------------- #

variable "management_groups_level1" {
  description = "Map of first level Management Group objects, nested under the core Manangement Group."
  type = map(object({
    display_name             = string
    parent_mg_name           = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values. 
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
    display_name             = string
    parent_mg_name           = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.  
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
    parent_mg_name           = string
    subscription_identifiers = optional(list(string)) # Optional list of subscription name identifier values.
  }))
  validation {
    condition = alltrue([
      for mg, details in var.management_groups_level3 : length(details.display_name) >= 3 && length(details.parent_mg_name) >= 3
    ])
    error_message = "Both a display name and parent Management Group is required for all Level 3 Management Groups."
  }
}

# POLICY ------------------------------------------------------------- #

variable "policy_initiatives_builtin" {
  description = "Map of objects containing built-in policy initiatives and their configuration settings."
  type = map(object({
    definition_id = string # ID of the initiative (4f5b1359-4f8e-4d7c-9733-ea47fcde891e). 
    enabled       = bool   # [true/false]: Toggle assignment.  
    enforce       = bool   # [true/false]: Toggle enforcement of policy initiative. 
  }))
}

variable "policy_effect_mode" {
  description = "String value to control the effect mode of policy assignments (audit, deployIfNotExists, disabled)."
  type        = string
}

variable "policy_enforce_mode" {
  description = "True/false value to control the enforcement mode of policy assignments."
  type        = bool
}

variable "policy_param_allowed_locations" {
  description = "List of allowed locations for resources in string format."
  type        = list(string)
}

variable "policy_param_required_tags" {
  description = "List of required tags to be assigned to resources in string format."
  type        = list(string)
}

variable "policy_param_allowed_vm_skus" {
  description = "List of allowed SKUs when deploying VMs."
  type        = list(string)
}
