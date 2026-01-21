# General  -----------------#

variable "stack_code" {
  description = "Short code used for stack resource naming."
  type        = string
}

variable "naming" {
  description = "A map of naming values to use with resources."
  type        = map(string)
  nullable    = false
}

# Governance: Policy Parameters -----------------#

variable "policy_custom_def_path" {
  description = "Local directory path containing custom policy definitions in JSON format."
  type        = string
  default     = "./policy_definitions"
}

