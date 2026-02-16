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

variable "global_outputs" {
  description = "Map of Shared Service key names, used to get IDs and names in data calls."
  type        = map(map(string))
}

variable "backend_categories" {
  description = "Backend category map, used to define the top-level IaC backend structure."
  type        = map(string) # WARNING: Changing this value will force re-creation of resources. Used by RG and SA. 
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
