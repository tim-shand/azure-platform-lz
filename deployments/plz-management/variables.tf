variable "subscription_id_iac" {
  description = "Subscription ID of the dedicated IaC subscription."
  type        = string
  nullable    = false
}

variable "subscription_id" {
  description = "Subscription ID for the stack resources."
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

variable "global_outputs" {
  description = "Map of Shared Service key names, used to get IDs and names in data calls."
  type        = map(map(string))
}

variable "global_outputs_name" {
  description = "Name of global outputs shared service App Configuration created during bootstrap."
  type        = string
}

variable "global_outputs_rg" {
  description = "Map of global outputs shared service Resource Group for App Configuration created during bootstrap."
  type        = string
}

# MANAGEMENT: General
# ------------------------------------------------------------- #

variable "law_retenion_days" {
  description = "Number of days to retain logs in Log Analytics Workspace."
  type        = number
  default     = 30
  validation {
    condition     = var.law_retenion_days >= 7 && var.law_retenion_days <= 180
    error_message = "Number of days to retain logs must be between 7 and 180 days."
  }
}

variable "law_archive_logs" {
  description = "Boolean value, enable to archive Log Analytics logs to Storage Account."
  type        = bool
  default     = false
}

variable "law_export_log_tables" {
  description = "List of table names to export to Storage Account."
  type        = list(string)
  default     = ["Alert", "Operation", "Metrics"]
}

variable "policy_diagnostic_settings_effect" {
  description = "Determines the effect mode when assigning policy to deploy diagnostic settings (DiagSettings)."
  type        = string
  default     = "Disabled"
}

variable "policy_activity_logs_effect" {
  description = "Determines the effect mode when assigning policy to deploy diagnostic settings (AzureActivity)."
  type        = string
  default     = "Disabled"
}

# MANAGEMENT: Action Groups
# ------------------------------------------------------------- #

variable "action_groups" {
  description = "Map of objects containing the action group definitions."
  type = map(object({
    email_address = list(string)
  }))
}

# MANAGEMENT: Alerts
# ------------------------------------------------------------- #

variable "activity_log_alerts" {
  description = "Map of alert group priorities."
  type        = any
}

# MANAGEMENT: Entra ID Logging
# ------------------------------------------------------------- #

variable "entraid_log_types" {
  description = "Map of Entra ID logging categories, boolean value to enable/disable."
  type        = map(bool)
}
