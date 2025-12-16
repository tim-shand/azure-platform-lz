variable "gov_management_group_list" {
  description = "Map of Management Group configuration to deploy."
  type = map(object({ # Use object variable name as management group 'name'.
    display_name      = string
    subscription_list = optional(list(strings))
  }))
}
