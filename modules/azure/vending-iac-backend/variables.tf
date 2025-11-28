#=================================================================#
# Azure IaC Backend: Variables
#=================================================================#

variable "iac_storage_account_rg" {
  description = "Resource Group of the Storage Account for IaC backends."
  type        = string
}

variable "iac_storage_account_name" {
  description = "Storage Account name for IaC backends."
  type        = string
}

variable "github_config" {
  description = "Map of values for GitHub configuration."
  type        = map(string)
}

variable "project_name" {
  description = "Name of project for new IaC backend."
  type        = string
}

variable "create_github_env" {
  description = "Toggle the creation of Github environment and variables."
  type        = bool
  default     = false
}

variable "enable_dev_state" {
  description = "Enable to create additional 'TF_BACKEND_KEY_DEV' environment variable."
  type        = bool
  default     = false
}
