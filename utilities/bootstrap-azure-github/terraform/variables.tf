#=================================================================#
# Azure Bootstrap: Variables
#=================================================================#

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

variable "repo_config" {
  description = "Map of repository settings (org/owner, repo, branch)."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "deployment_stacks" {
  description = "Map of objects listing the deployment stack (category: Platform, stacks: ...)"
  type = map(map(object({
    stack_name      = string
    subscription_id = string
    create_repo_env = bool # Enable creation of repo environment. 
  })))
}
