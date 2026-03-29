variable "terraform_version" {
  description = "Terraform version to use with workflows."
  type        = string
  nullable    = false
}

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

variable "bootstrap_stacks" {
  description = "Map of deployment objects listing the bootstrap stack details."
  type = map(object({
    stack_name              = string
    stack_code              = string
    subscription_identifier = string # Name part that is used in "contains" filter to resolve ID. 
  }))
}

variable "platform_stacks" {
  description = "Map of deployment objects listing the platform stack details."
  type = map(object({
    stack_name              = string
    stack_code              = string
    subscription_identifier = string # Name part that is used in "contains" filter to resolve ID. 
  }))
}
