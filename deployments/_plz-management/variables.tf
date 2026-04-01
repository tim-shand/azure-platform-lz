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

# Log Analytics ---------------------------------------------------- #

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics."
  type        = number
  default     = 30
}

variable "log_daily_quota_gb" {
  description = "Daily quota cap to prevent unexpected cost spikes. Using '-1' disables the cap (not recommended)."
  type        = number
  default     = 1
  validation {
    condition     = var.log_daily_quota_gb == -1 || var.log_daily_quota_gb >= 0.023
    error_message = "Daily quota must be -1 (unlimited) or >= 0.023 GB."
  }
}

variable "log_analytics_sku" {
  description = "The SKU to use for Log Analytics Workspace (PerGB2018, PerNode, Premium, Standalone, Standard, CapacityReservation, LACluster, Unlimited)."
  type        = string
  default     = "PerGB2018"
}



# Key Vault -------------------------------------------------------- #

variable "key_vault_soft_delete_retention_days" {
  description = "Numver of soft delete retention in days."
  type        = number
  default     = 30
  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

# Alerting -------------------------------------------------------- #

variable "alert_email_addresses" {
  description = "List of email addresses for platform alert notifications."
  type        = list(string)
  default     = []
}

variable "enable_log_alerts" {
  description = "Enable log-based alert rules."
  type        = bool
  default     = false
}
