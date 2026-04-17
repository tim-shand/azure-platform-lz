#====================================================================================#
# Management: Alerting Resources
# Description: 
# - Deploy Action Group to receive alerts when triggered. 
# - Deploy Azure Monitor activity alerts per category.
#====================================================================================#

# ACTION GROUPS ------------------------------------------------------------------ #

# Notification target for all platform alerts.
resource "azurerm_monitor_action_group" "platform" {
  count = var.enable_resource_deployment.alerting ? 1 : 0 # Only deploy if enabled.
  name                = "${module.naming.action_group}-platform"
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
  count = var.enable_resource_deployment.alerting ? 1 : 0 # Only deploy if enabled.
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
    action_group_id = azurerm_monitor_action_group.platform[0].id
  }
}

# Service Health Alerts: Covers Azure-side incidents, planned maintenance, health advisories, and security advisories.
resource "azurerm_monitor_activity_log_alert" "service_health" {
  count = var.enable_resource_deployment.alerting ? 1 : 0 # Only deploy if enabled.
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
    action_group_id = azurerm_monitor_action_group.platform[0].id
  }
}

# Administrative Alerts: Delete Attempts for Resource Groups.
resource "azurerm_monitor_activity_log_alert" "delete_rg" {
  count = var.enable_resource_deployment.alerting ? 1 : 0 # Only deploy if enabled.
  name                = "${module.naming.activity_log_alert}-delrg"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global"
  tags                = local.tags_merged
  description         = "Fires when Resource Group deletion is attempted."
  enabled             = var.enable_administrative_alerts
  scopes              = [data.azurerm_subscription.current.id] # Alerts are per subscription resource scope.
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/delete"
    statuses       = ["Succeeded", "Failed"]
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform[0].id
  }
}

# Administrative Alerts: Changes to RBAC Assignments
resource "azurerm_monitor_activity_log_alert" "rbac" {
  count = var.enable_resource_deployment.alerting ? 1 : 0 # Only deploy if enabled.
  name                = "${module.naming.activity_log_alert}-rbac"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global"
  tags                = local.tags_merged
  description         = "Fires when changesd to RBAC role assignments are made."
  enabled             = var.enable_administrative_alerts
  scopes              = [data.azurerm_subscription.current.id] # Alerts are per subscription resource scope.
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/roleAssignments/write"
    statuses       = ["Succeeded", "Failed"]
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform[0].id
  }
}

# Administrative Alerts: Policy Assignment Changes
resource "azurerm_monitor_activity_log_alert" "policy" {
  count = var.enable_resource_deployment.alerting ? 1 : 0 # Only deploy if enabled.
  name                = "${module.naming.activity_log_alert}-policy"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global"
  tags                = local.tags_merged
  description         = "Fires when changes to policy assignments are made."
  enabled             = var.enable_administrative_alerts
  scopes              = [data.azurerm_subscription.current.id] # Alerts are per subscription resource scope.
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/policyAssignments/write"
    statuses       = ["Succeeded", "Failed"]
  }
  action {
    action_group_id = azurerm_monitor_action_group.platform[0].id
  }
}
