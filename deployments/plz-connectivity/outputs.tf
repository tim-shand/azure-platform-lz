# CONNECTIVITY: General
# ------------------------------------------------------------- #

output "hub_subnets_enabled" {
  description = "List of enabled subnets in hub VNet."
  value       = local.hub_subnets_enabled
}
