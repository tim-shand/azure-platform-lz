# GLOBAL ----------------------------------------------------------- #
variable "global" {
  description = "Map of global variables used across multiple deployment stacks."
  type        = map(map(string))
  nullable    = false
  default     = {}
}

variable "subscription_id" {
  description = "Subscription ID for the stack resources."
  type        = string
  nullable    = false
}

# STACK ------------------------------------------------------------ #
