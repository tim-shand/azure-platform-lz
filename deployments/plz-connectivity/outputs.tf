output "hub_vnet" {
    description = "Map of hub Virtual Network properties."
    value = {
        id = azurerm_virtual_network.hub.id
        name = azurerm_virtual_network.hub.name
        resource_group = azurerm_virtual_network.hub.resource_group_name
    }
}

output "hub_firewall" {
    description = "Map of Azure Firewall properties."
    value = var.hub_firewall.enabled ? {
        id              = azurerm_firewall.hub[0].id
        name            = azurerm_firewall.hub[0].name
        resource_group  = azurerm_firewall.hub[0].resource_group_name
        policy_name     = azurerm_firewall_policy.hub[0].name
        public_ip       = azurerm_public_ip.fw[0].id
        public_ip_mgt   = azurerm_public_ip.fw_mgt[0].id
        subnet          = azurerm_subnet.fw[0].address_prefixes
        subnet_mgt      = azurerm_subnet.fw_mgt[0].address_prefixes
    } : null # Return NULL if firewall is not enabled.
}
