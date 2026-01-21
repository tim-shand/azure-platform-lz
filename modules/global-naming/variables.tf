# variable "sections" {
#   description = "Map of name sections. Key = section name, Value = string. Example: {org_prefix = 'abc', project = 'platform'}."
#   type        = map(string)
#   default     = {}
# }

variable "sections" {
  type        = list(string)
  description = "Ordered list of name sections: org, project, category1, category2."
}

variable "delimiter" {
  description = "Delimiter used for full names (default '-')."
  type        = string
  default     = "-"
}

variable "short_max_length" {
  description = "Maximum length for short names."
  type        = number
  default     = 24
}

variable "random_length" {
  description = "Length of optional random suffix for short names."
  type        = number
  default     = 6
}

variable "allowed_environment_codes" {
  description = "Allowed environment codes."
  type        = list(string)
  default     = ["dev", "tst", "stg", "prd", "alz", "plz"]
}

variable "environment" {
  description = "Optional environment code, validate against existing allowed list."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition     = var.environment == null || contains(var.allowed_environment_codes, var.environment)
    error_message = "Environment must match one of ${join(", ", var.allowed_environment_codes)}"
  }
}

variable "append_random" {
  description = "Append a random string to short names if truncated."
  type        = bool
  default     = true
}
