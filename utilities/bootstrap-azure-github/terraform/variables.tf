#=================================================================#
# Azure Bootstrap: Variables
#=================================================================#

# variable "subscription_id_iac" {
#   description = "Subscription ID to use for dedicated IaC backends."
#   type        = string
#   nullable    = false
# }

variable "global" {
  description = "Map of global settings for the Azure environment."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "naming" {
  description = "Map of naming parameters to use with resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "tags" {
  description = "Map of tags to apply to resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "github_config" {
  description = "Map of GitHub settings (org/owner, repo, branch)."
  type        = map(string)
  nullable    = false
  default     = {}
}

# variable "plz_stacks" {
#   description = "Map of objects defining the configuration per PLZ stack."
#   type = map(object({
#     stack_name      = string
#     subscription_id = string
#   }))
#   nullable = false
# }

# Test

variable "deployment_stacks" {
  description = ""
  type = map(map(object({
    stack_name        = string
    subscription_id   = string
    create_github_env = bool
  })))
}
