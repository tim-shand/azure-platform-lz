# Variables

variable "prefix" {
  type        = string
  description = "Organisation prefix/abbreviation. Example: abc."
}

variable "workload" {
  type        = string
  description = "Workload or project name. Example: plz or mywebapp."
}

variable "stack_or_env" {
  type        = string
  description = "Deployment stack or environment. Example: con, gov, prd, dev, tst."
}

variable "category" {
  type        = string
  default     = ""
  description = "Optional category for platform or service based grouping. Example: hub, log, www."
}

variable "max_length_full" {
  type        = number
  default     = 64
  description = "Maximum length for full, dash separated names."
}

variable "max_length_compact" {
  type        = number
  default     = 24
  description = "Maximum length of compact names (for restricted resources like Storage Accounts)."
}

variable "ensure_unique" {
  type        = bool
  default     = false
  description = "Enable to append a random suffix for unique naming."
}

variable "random_length" {
  type        = number
  default     = 6
  description = "Length of random string if uniqueness is required."
}
