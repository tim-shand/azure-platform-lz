# GENERAL ----------------------------------------------------------- #

variable "terraform_version" {
  description = "Version of Terraform to pin for use in workflows."
  type = string
  default = ""
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

variable "subscription_id" {
  description = "Subscription ID for the stack deployment."
  type        = string
  nullable    = false
}

variable "subscription_id_iac" {
  description = "Subscription ID for the IaC backend deployment."
  type        = string
  nullable    = false
}

variable "remote_state_resource_group" {
  description = "Name of the Resource Groups that contains remote state backends."
  type = string
  default = ""
}

variable "remote_state_storage_account" {
  description = "Name of the Storage Account that contains remote state backends."
  type = string
  default = ""
}

variable "deployment_stacks" {
  description = "Map of objects defining the stacks for each deployment."
  type = map(object({
    stack_name              = string
    stack_code              = string
    subscription_identifier = string
    enable_github_env       = bool
  }))
}

# RESOURCE SWITCH ------------------------------------------------------------- #

variable "enable_resource_deployment" {
  description = "Enable/disable specific resources for deployment."
  type = map(string)
  default = {
    alerting = true
    defender_for_cloud = true
    key_vault = true
    logging = true
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

variable "log_archiving_storage_account" {
  description = "Configuration for log archiving to storage account."
  type = object({
    enabled = bool
    tables = map(bool) 
  })
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

variable "action_groups" {
  description = "Map of Action Groups to receive alerts."
  type = map(object({
    name = string 
    email = string
    enabled = bool
  }))
}

variable "enabled_alerts" {
  description = "Enable or disable alert categories."
  type = map(bool)
  default = {
    resource_health = true
    service_health  = true
    administrative  = true
  }
}

variable "mdfc_alerts" {
  description = "Map of bools to control MDFC alerting."
  type = map(bool)
  default = {
    alert_notifications = true # Send security alerts notifications to the security contact.
    alerts_to_admins    = false # Send security alerts notifications to subscription admins.
  }
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

# ENTRA ID GROUPS ----------------------------------------------- #

variable "entra_groups_prefix" {
  description = "String value to use for Entra ID group naming prefix."
  type = string
  default = "GRP_ADM_"
}

variable "entra_groups_privilaged" {
  description = "Map of objects containing privilaged Entra ID groups to create."
  type = map(object({
    description = string
    active = bool
    roles = list(string)
  }))
}

variable "entraid_log_types" {
  description = "Map of Entra ID log categories with enable status."
  type = map(bool)
}
