#====================================================================================#
# Connectivity: Azure Firewall Policy
# Description: 
# - Define Azure Firewall policy configuration.
#====================================================================================#

# Firewall Policy
resource "azurerm_firewall_policy" "hub" {
  name                = "${module.naming_con.full_name}-fwl-policy"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku                 = var.hub_firewall.policy_sku
}

# Application Rules
resource "azurerm_firewall_application_rule_collection" "default" {
  name                = "plz-default-application"
  azure_firewall_name = azurerm_firewall.hub.name
  resource_group_name = azurerm_resource_group.con.name
  priority            = 100
  action              = "Allow"

  dynamic "rule" {
    for_each = var.firewall_rules_default_application
    content {
      name = each.name
    }
  }
  #   rule {
  #     name = "testrule"
  #     source_addresses = [
  #       "10.0.0.0/16",
  #     ]
  #     target_fqdns = [
  #       "*.google.com",
  #     ]
  #     protocol {
  #       port = "443"
  #       type = "Https"
  #     }
  #   }
}
