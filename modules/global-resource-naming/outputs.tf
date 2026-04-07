# GENERAL ---------------------------------------- #

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

output "management_group" { value = "mg-${local.full_name}" }
output "resource_group" { value = "rg-${local.full_name}" }
output "storage_account" { value = "sa${local.compact_name_unique}" }
output "key_vault" { value = "kv-${local.full_name_unique}" }
output "virtual_network" { value = "vnet-${local.full_name}" }
output "subnet" { value = "snet-${local.full_name}" }
output "log_analytics_workspace" { value = "law-${local.full_name}" }
output "user_assigned_managed_identity" { value = "uai-${local.full_name}" }
output "azure_firewall" { value = "afw-${local.full_name}" }
output "azure_firewall_policy" { value = "afwp-${local.full_name}" }
output "bastion" { value = "bas-${local.full_name}" }
output "gateway_vpn" { value = "vpng-${local.full_name}" }
output "gateway_express_route" { value = "ergw-${local.full_name}" }
output "public_ip" { value = "pip-${local.full_name}" }
output "service_principal" { value = "sp-${local.full_name}" }
output "data_collection_endpoint" { value = "dce-${local.full_name}" }
output "data_collection_rule" { value = "dcr-${local.full_name}" }
output "action_group" { value = "ag-${local.full_name}" }
output "activity_log_alert" { value = "alrt-${local.full_name}" }
