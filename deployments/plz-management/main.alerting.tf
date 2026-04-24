#====================================================================================#
# Management: Alerts
# Description: 
# - Deploy Azure Monitor activity alerts per category.
#====================================================================================#

# ALERTS (HEALTH) ------------------------------------------------------------------------- #

# Resource Health Alerts: Monitor individual resource availability.
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  name                = "${module.naming.activity_log_alert}-hth-res"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  description         = "Fires when any resource in the management resource group becomes unavailable or degraded."
  enabled             = var.enabled_alerts.resource_health
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  criteria {
    category = "ResourceHealth"
    resource_health {
      current  = ["Unavailable", "Degraded"]
      previous = ["Available", "Unknown"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.mgt["platform"].id
  }
}

# Service Health Alerts: Covers Azure-side incidents, planned maintenance, health advisories, and security advisories.
resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "${module.naming.activity_log_alert}-hth-srv"
  resource_group_name = azurerm_resource_group.mgt.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  description         = "Fires when Azure reports an active service incident affecting this subscription."
  enabled             = var.enabled_alerts.service_health
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  criteria {
    category = "ServiceHealth"
    service_health {
      locations = local.locations_all # Flattened list.
      events    = ["Incident", "Maintenance", "Security"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.mgt["platform"].id
  }
}

# ALERTS (ADMINISTRATIVE) ------------------------------------------------------------------------- #

module "alert_rg_delete" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-delrg"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Resources/subscriptions/resourceGroups/delete"
  action_group_id     = azurerm_monitor_action_group.mgt["platform"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}

module "alert_rbac_add" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-rbacadd"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Authorization/roleAssignments/write"
  action_group_id     = azurerm_monitor_action_group.mgt["security"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}

module "alert_rbac_del" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-rbacdel"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Authorization/roleAssignments/delete"
  action_group_id     = azurerm_monitor_action_group.mgt["security"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}

module "alert_policy_add" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-policyadd"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Authorization/policyAssignments/write"
  action_group_id     = azurerm_monitor_action_group.mgt["platform"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}

module "alert_policy_del" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-policydel"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Authorization/policyAssignments/delete"
  action_group_id     = azurerm_monitor_action_group.mgt["platform"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}

module "alert_vnet_del" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-vnetdel"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Network/virtualNetworks/delete"
  action_group_id     = azurerm_monitor_action_group.mgt["platform"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}

module "alert_pip_add" {
  source = "../../modules/activity-log-alert"
  name                = "${module.naming.activity_log_alert}-pipadd"
  resource_group_name = azurerm_resource_group.mgt.name
  tags                = local.tags_merged
  #scopes              = local.platform_subscription_scopes
  scopes              = data.azurerm_subscription.current.id
  operation_name      = "Microsoft.Network/publicIPAddresses/write"
  action_group_id     = azurerm_monitor_action_group.mgt["security"].id
  statuses            = ["Succeeded", "Failed"]
  enabled             = var.enabled_alerts.administrative
}
