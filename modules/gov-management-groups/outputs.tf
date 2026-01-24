output "root_id" {
  description = "ID of the root Management Group."
  value       = azurerm_management_group.root["core"].id
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

output "management_groups_subs_level5" {
  value = azurerm_management_group.level5
}

output "management_groups_all" {
  value = merge(
    azurerm_management_group.root,
    azurerm_management_group.level1,
    azurerm_management_group.level2,
    azurerm_management_group.level3,
    azurerm_management_group.level4
  )
}
