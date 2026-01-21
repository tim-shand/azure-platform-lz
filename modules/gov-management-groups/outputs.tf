output "management_group_root_id" {
  description = "ID of the top-level (root) Management Group."
  value       = azurerm_management_group.root.id
}

output "management_groups_subs_level1" {
  value = azurerm_management_group.level1
}

output "management_groups_subs_level2" {
  value = azurerm_management_group.level2
}

output "management_groups_subs_level3" {
  value = azurerm_management_group.level3
}

output "management_groups_subs_level4" {
  value = azurerm_management_group.level4
}

output "management_group_subscriptions" {
  value = merge(
    azurerm_management_group.level1,
    azurerm_management_group.level2,
    azurerm_management_group.level3,
    azurerm_management_group.level4
  )
}
