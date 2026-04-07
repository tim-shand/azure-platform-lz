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

# REMOTE STATE ------------------------------------------------------------- #

variable "remote_state_iac" {
  description = "Map of values used to call the remote state data."
  type        = map(string)
  default = {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = ""
    use_azuread_auth     = true # Force Entra ID for authorisation over Shared Access Keys.
  }
}

# LOGGING ---------------------------------------------------- #

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

variable "log_archive_retention_days" {
  description = "Number of days until deletion from archive."
  type        = number
  default     = 180
}

# KEY VAULT -------------------------------------------------------- #

variable "key_vault_soft_delete_retention_days" {
  description = "Number of soft delete retention in days."
  type        = number
  default     = 30
  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

variable "key_vault_soft_purge_protection" {
  description = "Enable purge protection on Key Vault (true/false)."
  type        = bool
  default     = false
}

# ALERTING -------------------------------------------------------- #

variable "alert_email_addresses" {
  description = "List of email addresses for platform alert notifications."
  type        = list(string)
  default     = []
}

variable "enable_alerts" {
  description = "Master switch to enable/disable log-based alert rules."
  type        = bool
  default     = false
}

variable "enable_resource_health_alerts" {
  description = "Enable alerting for resource health."
  type        = bool
  default     = true
}

variable "enable_service_health_alerts" {
  description = "Enable alerting for service health."
  type        = bool
  default     = true
}

variable "enable_administrative_alerts" {
  description = "Enable alerting for administrative actions."
  type        = bool
  default     = true
}

variable "alert_on_resource_deletion" {
  description = "List of resource types to alert on if deletion is attempted."
  type        = list(string)
  default = [
    "/providers/Microsoft.KeyVault/vaults/*",
    "/providers/Microsoft.OperationalInsights/workspaces/*",
    "/providers/Microsoft.Insights/diagnosticSettings/*"
  ]
}

# DEFENDER FOR CLOUD ----------------------------------------------- #

variable "mdfc_enable_defender_cspm" {
  description = "Enable the paid tier of Defender for Cloud for extended security, comprehensive security assessments."
  type        = bool
  default     = false
}

variable "mdfc_cspm_resources" {
  description = "Enable or disable specific resource types for MDfC CSPM."
  type        = map(bool)
}
