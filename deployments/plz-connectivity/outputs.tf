# CONNECTIVITY: General
# ------------------------------------------------------------- #

output "hub_fwl_ips" {
  description = "Output of the hub firewall IP configuration."
  value       = azurerm_firewall.hub[0].ip_configuration
}

output "hub_fwl_ips_mgt" {
  description = "Output of the hub firewall management IP configuration."
  value       = azurerm_firewall.hub[0].ip_configuration
}
