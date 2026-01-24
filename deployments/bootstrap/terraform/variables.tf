#=================================================================#
# Azure Bootstrap: Variables
#=================================================================#

variable "global" {
  description = "Map of global settings (naming, tags, location)."
  type        = map(map(string))
  nullable    = false
  default     = {}
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

variable "deployment_stacks" {
  description = "Map of objects listing the deployment stack (category: Platform, stacks: ...)"
  type = map(object({
    category        = string
    stack_name      = string
    subscription_id = string
    create_repo_env = bool # Enable creation of repo environment. 
  }))
}

# Globals: Key Vault ----------------------------------------------------------|
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
