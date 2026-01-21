# Governance: Management Groups -----------------#

variable "naming" {
  description = "A map of naming values to use with resources."
  type        = map(string)
  default     = {}
}

variable "management_group_root" {
  description = "Name of the top-level Management Group (root)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.management_group_root)) # Only allow alpha-numeric with dashes.
    error_message = "Only letters, numbers, and dashes (-) are allowed. No spaces or other symbols."
  }
}

variable "subscription_prefixes" {
  description = "A map of Management Group to Subscritpion membership."
  type        = map(list(string))
  default     = {}
}
