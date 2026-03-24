#====================================================================================#
# Connectivity: Azure Firewall Policy
# Description: 
# - Define Azure Firewall policy configuration.
#====================================================================================#

# Firewall Policy
resource "azurerm_firewall_policy" "hub" {
  count               = var.hub_firewall.enabled ? 1 : 0 # Only create if enabled.
  name                = "${module.naming_con.full_name}-fwl-policy"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku                 = var.hub_firewall.policy_sku
}

# Firewall Policy Rule Collection
resource "azurerm_firewall_policy_rule_collection_group" "default" {
  count              = var.hub_firewall.enabled ? 1 : 0 # Only create if enabled.
  name               = "plz-default-rcg"
  firewall_policy_id = azurerm_firewall_policy.hub[0].id
  priority           = 100
  # Loop each rule in TFVARS file, looping each child object (rule, protocols).

  # Application Rules
  dynamic "application_rule_collection" {
    for_each = var.firewall_policy_rule_collections.application
    content {
      name     = application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name              = rule.key
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }

  # Network Rules
  dynamic "network_rule_collection" {
    for_each = var.firewall_policy_rule_collections.network
    content {
      name     = network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.key
          source_addresses      = rule.value.source_addresses
          destination_ports     = rule.value.destination_ports
          protocols             = rule.value.protocols
          destination_addresses = try(rule.value.destination_addresses, null) # Ignore if not present.
          destination_fqdns     = try(rule.value.destination_fqdns, null)     # Ignore if not present.
        }
      }
    }
  }
}
