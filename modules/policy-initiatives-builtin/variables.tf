variable "naming" {
  description = "A map of naming values to use with resources."
  type        = map(string)
  default     = {}
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
