output "storage_account_name" {
  description = "Name of the created Storage Account."
  value       = azurerm_storage_account.main.name
}

output "resource_group" {
  description = "Resource Group of the created Storage Account."
  value       = azurerm_storage_account.main.resource_group_name
}
