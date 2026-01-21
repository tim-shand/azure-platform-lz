# General  -----------------#

variable "subscription_id" {
  description = "Subscription ID for the target changes. Provided by workflow variable."
  type        = string
}

variable "repo_config" {
  description = "Map of repository settings (org/owner, repo, branch)."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "global" {
  description = "Map of global settings (naming, tags, location)."
  type        = map(map(string))
  nullable    = false
  default     = {}
}

variable "naming" {
  description = "Map of deployment naming parameters to use with resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "tags" {
  description = "Map of deployment tags to apply to resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

# Governance: Management Groups -----------------#

variable "management_group_root" {
  description = "Name of the top-level Management Group (root)."
  type        = string
  default     = "Core"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.management_group_root)) # Only allow alpha-numeric with dashes.
    error_message = "Management Group IDs can only contain letters, numbers, and dashes (-). No spaces or other symbols are allowed."
  }
}

variable "subscription_prefixes" {
  description = "A map of Management Group to Subscritpion membership."
  type        = map(list(string))
  default     = {}
}

# Governance: Policy Parameters -----------------#

variable "policy_initiatives_builtin" {
  description = "Set of display name for built-in policy initiatives to assign at root management group."
  type        = set(string)
  default     = []
  nullable    = true
}

variable "policy_initiatives_builtin_enforce" {
  description = "Enable to enforce the built-in policy initiative."
  type        = bool
  default     = false
}

variable "policy_initiatives_builtin_enable" {
  description = "Enable assignment of the built-in policy initiative (turns it on/off)."
  type        = bool
  default     = true
}

variable "policy_custom_allowed_locations" {
  description = "Object of policy settings that determine values and effect for allowed locations."
  type = object({
    effect    = string       # Audit, Deny, Disabled
    locations = list(string) # List of allowed locations allowed when deploying resources.
  })
  default = {
    effect    = "audit"
    locations = ["newzealandnorth"]
  }
  validation {
    condition     = length(var.policy_custom_allowed_locations.locations) >= 1
    error_message = "At least one allowed location must be provided."
  }
}

variable "policy_custom_required_tags" {
  description = "Object of policy settings that determine values and effect for required tags."
  type = object({
    effect = string       # Audit, Deny, Disabled
    tags   = list(string) # List of required tags when deploying resources.
  })
  default = {
    effect = "audit"
    tags   = ["Owner", "Environment", "Project"]
  }
  validation {
    condition     = length(var.policy_custom_required_tags.tags) >= 1
    error_message = "At least three tag names MUST be provided."
  }
}

variable "policy_custom_def_path" {
  description = "Local directory path containing custom policy definitions in JSON format."
  type        = string
  default     = "./policy_definitions"
}
