#====================================================================================#
# Management: Action Groups
# Description: 
# - Deploy Action Groups to receive alerts when triggered. 
#====================================================================================#

# ACTION GROUPS ------------------------------------------------------------------ #

# Notification target for all platform alerts.
resource "azurerm_monitor_action_group" "mgt" {
  for_each            = local.action_groups_enabled
  name                = "${module.naming.action_group}-${each.key}"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  short_name          = "alerts-plz"
  email_receiver {
    name = each.value.name
    email_address = each.value.email
  }
}
