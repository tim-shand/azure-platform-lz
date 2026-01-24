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

variable "tags" {
  description = "Map of deployment tags to apply to resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "subscription_id" {
  description = "Subscription ID for the target changes. Provided by workflow variable or terminal input."
  type        = string
  validation { # Functions to verify if the string can be parsed as a UUID, catch invalid or mising characters. 
    condition     = length(var.subscription_id) == 36
    error_message = "The subscription ID must be a valid 36-character GUID."
  }
}

variable "global_outputs_kv" {
  description = "Map of details for global outputs Key Vault. Passed in via command line or workflow."
  type        = map(string)
  nullable    = false
  default     = {}
}

# Entra ID ----------------------------------------------------------|
variable "entra_groups" {
  description = "Map of objects defining the default Entra ID groups to deploy."
  type = map(object({
    display_name = string
    description  = string
  }))
}

# RBAC ----------------------------------------------------------|
variable "group_role_assignments" {
  type = map(object({
    role_name    = string # Azure built-in role or custom role. 
    scope_type   = string # management_group | subscription | resource_group
    scope_target = string # Name or ID of the target (MG name). 
  }))
}

# Key Vault ----------------------------------------------------------|
variable "kv_sku" {
  description = "Key Vault SKU to use for Identity stack."
  type        = string
  default     = "standard"
}

variable "kv_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted key vault."
  type        = number
  default     = 7
}

variable "kv_purge_protection_enabled" {
  description = "Enable purge protection on the Key Vault."
  type        = bool
  default     = false
}
