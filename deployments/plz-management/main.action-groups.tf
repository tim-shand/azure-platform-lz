#====================================================================================#
# Management: Action Groups
# Description: 
# - Define Action Groups for alert notifications. 
#====================================================================================#

# Action Groups: Define actions to be taken when triggered. 
resource "azurerm_monitor_action_group" "all" {
  for_each            = var.action_groups # Use TFVARS. 
  name                = lower("${module.naming_mgt_alerts.full_name}-${each.key}-ag")
  short_name          = upper(each.key)
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  tags                = local.tags_merged
  dynamic "email_receiver" {
    for_each = each.value.email_address # Loop each email address in priority list. 
    content {
      name                    = "Email_${each.key}_${email_receiver.value}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}
