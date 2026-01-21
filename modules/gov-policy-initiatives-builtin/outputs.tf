output "configuration" {
  description = "State of built-in policy initiative assignments."
  value = {
    for k, v in azurerm_management_group_policy_assignment.builtin :
    k => {
      name    = v.display_name
      enforce = v.enforce
    }
  }
}
