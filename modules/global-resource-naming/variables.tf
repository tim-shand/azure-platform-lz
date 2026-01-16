
variable "org_prefix" {
  description = "Abbreviation code (3-6 characters) used to represent the organisation."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.org_prefix) >= 3 && length(var.org_prefix) <= 6
    error_message = "Organisation prefix length must be equal to or greater than 3, and less than or equal to 6 characters"
  }
}

variable "project" {
  description = "Name of the workload or project (3-10 characters) for which resources will be used."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.project) >= 3 && length(var.project) <= 10
    error_message = "Project length must be equal to or greater than 3, and less than or equal to 10 characters"
  }
}

variable "category1" {
  description = "Primary category name (3-6 characters) used to break up generic structures (e.g. gov, sec, con)."
  type        = string
  default     = null
  validation {
    condition     = var.category1 != null || length(var.category1) >= 3 && length(var.category1) <= 6
    error_message = "Category1 length must be equal to or greater than 3, and less than or equal to 6 characters"
  }
}

variable "category2" {
  description = "Secondary category name (3-6 characters) used to break up generic structures (e.g. log, soc, hub)."
  type        = string
  default     = null
  validation {
    condition     = var.category2 != null || length(var.category2) >= 3 && length(var.category2) <= 6
    error_message = "Category1 length must be equal to or greater than 3, and less than or equal to 6 characters"
  }
}

variable "environment" {
  description = "Short code (3 characters) representing for the desired environment (e.g. dev, tst, stg, prd, alz, plz)."
  type        = string
  nullable    = false
  validation {
    condition     = contains(["dev", "tst", "stg", "prd", "plz", "alz"], var.environment) && length(var.environment) == 3
    error_message = "Environment must match an allowed value (dev, tst, stg, prd, plz, alz)."
  }
}
