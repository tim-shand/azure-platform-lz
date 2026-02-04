output "management_groups_all" {
  value = merge(
    azurerm_management_group.level1,
    azurerm_management_group.level2,
    azurerm_management_group.level3
  )
}
