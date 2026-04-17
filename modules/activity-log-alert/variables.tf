variable "name" {
  description = "Name of the alert."
  type = string
}

variable "resource_group_name" {
  description = "Resource Group name where the alert will be created."
  type = string
}

variable "location" {
  description = "Location where the alert will be created."
  type = string
  default = "global"
}

variable "tags" {
  description = "Map of tags to apply to alert resource."
  type = map(string)
}

variable "scopes" {
  description = "Scope such as subscription or Resource Group."
  type = list(string)
}

variable "statuses" {
  description = "List of statuses to apply to the alerting rule."
  type = list(string)
  default = ["Succeeded", "Failed"]
}

variable "operation_name" {
  description = "Type of action to alert on."
  type = string
}

variable "category" {
  type    = string
  default = "Administrative"
}

variable "action_group_id" {
  description = "ID of the ACtion Group to receive alerts."
  type = string
}

variable "severity" {
  type    = number
  default = 2
}

variable "enabled" {
  type    = bool
  default = true
}
