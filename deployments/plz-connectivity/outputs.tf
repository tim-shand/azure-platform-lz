# CONNECTIVITY: General
# ------------------------------------------------------------- #

output "hub_services_enabled" {
  description = "Map of enabled hub services."
  value       = local.hub_services_enabled
}
