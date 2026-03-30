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

# RESOURCES -------------------------------------- #

output "resource_group" {
  description = "Full length name separated by dashes."
  value       = "rg-${local.full_name}"
}

output "storage_account" {
  description = "Pre-determined name for Storage Account."
  value       = "sa${local.compact_name_unique}"
}

output "key_vault" {
  description = "Pre-determined name for Key Vault."
  value       = "kv-${local.compact_name_unique}"
}

output "virtual_network" {
  description = "Full length name separated by dashes."
  value       = "vnet-${local.full_name}"
}

output "subnet" {
  description = "Full length name separated by dashes."
  value       = "snet-${local.full_name}"
}

output "log_analytics_workspace" {
  description = "Full length name separated by dashes."
  value       = "law-${local.full_name}"
}

output "user_assigned_managed_identity" {
  description = "Full length name separated by dashes."
  value       = "uai-${local.full_name}"
}

output "azure_firewall" {
  description = "Full length name separated by dashes."
  value       = "afw-${local.full_name}"
}

output "azure_firewall_policy" {
  description = "Full length name separated by dashes."
  value       = "afwp-${local.full_name}"
}

output "bastion" {
  description = "Full length name separated by dashes."
  value       = "bas-${local.full_name}"
}

output "gateway_vpn" {
  description = "Full length name separated by dashes."
  value       = "vpng-${local.full_name}"
}

output "gateway_express_route" {
  description = "Full length name separated by dashes."
  value       = "ergw-${local.full_name}"
}

output "public_ip" {
  description = "Full length name separated by dashes."
  value       = "pip-${local.full_name}"
}

output "service_principal" {
  description = "Full length name separated by dashes."
  value       = "sp-${local.full_name}"
}
