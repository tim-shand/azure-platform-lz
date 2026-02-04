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

variable "shared_services_kv_name" {
  description = "Name of shared service Key Vault created during bootstrap."
  type        = string
}

variable "shared_services_kv_rg" {
  description = "Map of shared service Resource Group for Key Vault created during bootstrap."
  type        = string
}
