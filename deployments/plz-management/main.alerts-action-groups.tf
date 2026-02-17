#====================================================================================#
# Management: Action Groups + Activity Alert Rules
# Description: 
# - Define Action Groups for alert notifications. 
# - Define Alert Rules for Activity Logs on resources. 
#====================================================================================#

# Action Groups: Define actions to be taken when triggered. 
resource "azurerm_monitor_action_group" "all" {
  for_each            = var.action_groups # Use TFVARS. 
  name                = "${module.naming_mgt_alerts.full_name}-${each.key}-ag"
  short_name          = "Alerts-${upper(each.key)}"
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

# Alert: Multiple Categories, defined in TFVARS.  
resource "azurerm_monitor_activity_log_alert" "all" {
  for_each            = var.activity_log_alerts
  name                = "ActivityLog-${each.key}"
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = [data.azurerm_app_configuration_key.mg_platform_id.value] # Assign at platform management group. 
  criteria {
    category = each.key
  }
  action {
    action_group_id = local.action_group_map[each.value] # each.value is the severity level ("p1", "p2"). 
  }
}
