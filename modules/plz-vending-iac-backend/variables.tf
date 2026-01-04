#=================================================================#
# Azure IaC Backend: Variables
#=================================================================#

variable "iac_storage_account_rg" {
  description = "Existing Resource Group of the Storage Account for IaC backends."
  type        = string
  nullable    = false
}

variable "iac_storage_account_name" {
  description = "Existing Storage Account name for IaC backends."
  type        = string
  nullable    = false
}

variable "github_config" {
  description = "Map of values for GitHub configuration."
  type        = map(string)
  nullable    = false
}

variable "project_name" {
  description = "Name of project for new IaC backend."
  type        = string
  nullable    = false
}

variable "create_github_env" {
  description = "Toggle the creation of GitHub environment and variables."
  type        = bool
  default     = false
}
