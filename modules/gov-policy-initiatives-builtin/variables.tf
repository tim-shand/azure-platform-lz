variable "naming_prefix" {
  description = "String value used for resource naming."
  type        = string
}

variable "builtin_initiatives" {
  description = "Set of display name for built-in policy initiatives to assign at root management group."
  type        = set(string)
  default     = []
}

variable "enforce" {
  description = "Enable to enforce the built-in policy initiative."
  type        = bool
  default     = false
}

variable "target_management_group_id" {
  description = "ID of the Management Group to assign the built-in policy definition."
  type        = string
}
