#=================================================================#
# Azure Bootstrap: Variables
#=================================================================#

variable "repo_config" {
  description = "Map of repository settings (org/owner, repo, branch)."
  type        = map(string)
  nullable    = false
  default     = {}
}

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
