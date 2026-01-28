# Outputs

output "full_name" {
  description = "Full length name separated by dashes."
  value       = local.full_name
}

output "full_name_unique" {
  description = "Full length name separated by dashes, with a unique suffix."
  value       = local.full_name_unique
}

output "compact_name" {
  description = "Compact name with no separator (truncated if necessary)."
  value       = local.compact_name
}

output "compact_name_long" {
  description = "Compact name with no separator, not truncated."
  value       = local.compact_base_clean
}

output "compact_name_unique" {
  description = "Compact name with no separator and unique suffix (truncated to max_length_compact)."
  value       = local.compact_name_unique
}

output "storage_account_name" {
  description = "Pre-determined name for Storage Account."
  value       = "${local.compact_name_unique}sa"
}

output "key_vault_name" {
  description = "Pre-determined name for Key Vault."
  value       = "${local.compact_name_unique}kv"
}
