output "name_full" {
  description = "Full length naming structure."
  value       = module.naming.full
}

output "name_short" {
  description = "Short length naming structure (remove delimiter and condense length)."
  value       = module.naming.short
}

output "storage_account_name" {
  description = "Name of the created Storage Account."
  value       = module.dev_sa.storage_account_name
}
