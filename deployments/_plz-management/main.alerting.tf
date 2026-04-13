#====================================================================================#
# Management: Alerting Resources
# Description: 
# - Deploy Action Group to receive alerts when triggered. 
# - Deploy Azure Monitor activity alerts per category.
#====================================================================================#

# ACTION GROUPS ------------------------------------------------------------------ #

# Notification target for all platform alerts.
resource "azurerm_monitor_action_group" "platform" {
  name                = "${module.naming.action_group}-support"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  short_name          = "alerts-plz"
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${index(var.alert_email_addresses, email_receiver.value)}"
      email_address = email_receiver.value
    }
  }
}

# ALERTS ------------------------------------------------------------------------- #

# Resource Health Alerts: Monitor individual resource availability.
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  name                = "${module.naming.activity_log_alert}-hth-res"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  description         = "Fires when any resource in the management resource group becomes unavailable or degraded."
  enabled             = var.enable_resource_health_alerts
  scopes              = [data.azurerm_subscription.current.id] # Alerts are per subscription resource scope.
  criteria {
    category = "ResourceHealth"
    resource_health {
      current  = ["Unavailable", "Degraded"]
      previous = ["Available", "Unknown"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

# Service Health Alerts: Covers Azure-side incidents, planned maintenance, health advisories, and security advisories.
resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "${module.naming.activity_log_alert}-hth-srv"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  description         = "Fires when Azure reports an active service incident affecting this subscription."
  enabled             = var.enable_service_health_alerts
  scopes              = [data.azurerm_subscription.current.id] # Alerts are per subscription resource scope.
  criteria {
    category = "ServiceHealth"
    service_health {
      locations = local.locations_all # Flattened list.
      events    = ["Incident", "Maintenance", "Security"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

# Administrative Alerts: Delete Attempts.
resource "azurerm_monitor_activity_log_alert" "delete_attempt_resources" {
  name                = "${module.naming.activity_log_alert}-del-res"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global"
  tags                = local.tags_merged
  description         = "Fires when specified resource types are attempted to be deleted (Succeeded or Failed)."
  enabled             = var.enable_administrative_alerts
  scopes              = [data.azurerm_subscription.current.id] # Alerts are per subscription resource scope.
  criteria {
    category       = "Administrative"
    operation_name = "*/delete"
    statuses       = ["Succeeded", "Failed"]
    resource_id    = local.alert_deletion_resource_id
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}
