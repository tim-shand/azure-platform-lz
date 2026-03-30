# GENERAL ----------------------------------------------------------- #

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

variable "subscription_id" {
  description = "Subscription ID for the stack deployment."
  type        = string
  nullable    = false
}

# STACK ------------------------------------------------------------ #

# Subscription IDs for deployment stacks.
variable "platform_subscriptions" {
  type = object({
    mgt = string
    gov = string
    con = string
  })
  nullable = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.platform_subscriptions.mgt))
    error_message = "The subscription_id must be a valid GUID."
  }
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.platform_subscriptions.gov))
    error_message = "The subscription_id must be a valid GUID."
  }
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.platform_subscriptions.con))
    error_message = "The subscription_id must be a valid GUID."
  }
}
