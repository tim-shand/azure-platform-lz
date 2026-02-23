#====================================================================================#
# Management: Activity Alert Rules
# Description: 
# - Define Alert Rules for Activity Logs on resources. 
# - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert
#====================================================================================#

# Alerts: Administrative
resource "azurerm_monitor_activity_log_alert" "administrative" {
  name                = lower("${module.naming_mgt_alerts.full_name}-admin-ar") # "ActivityLog-${each.key}"
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = local.platform_subs # Assign to platform subscriptions.  
  enabled             = var.activity_log_alerts.Administrative.enabled
  criteria {
    category = "Administrative"
    level    = try(var.activity_log_alerts.Administrative.level, null) # Define the severity levels ("Verbose", "Informational", "Warning", "Error", "Critical"). 
    statuses = var.activity_log_alerts.Administrative.statuses         # Define the status events ("Started", Failed", "Succeeded").
  }
  action {
    action_group_id = local.action_group_ids[var.activity_log_alerts["Administrative"].action_group]
  }
}

# Alerts: Policy
resource "azurerm_monitor_activity_log_alert" "policy" {
  name                = lower("${module.naming_mgt_alerts.full_name}-policy-ar") # "ActivityLog-${each.key}"
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = local.platform_subs # Assign to platform subscriptions.  
  enabled             = var.activity_log_alerts.Policy.enabled
  criteria {
    category = "Policy"
    level    = try(var.activity_log_alerts.Policy.level, null) # Define the severity levels ("Verbose", "Informational", "Warning", "Error", "Critical"). 
    statuses = var.activity_log_alerts.Policy.statuses         # Define the status events ("Started", Failed", "Succeeded").
  }
  action {
    action_group_id = local.action_group_ids[var.activity_log_alerts["Policy"].action_group]
  }
}

# Alerts: Security
resource "azurerm_monitor_activity_log_alert" "security" {
  name                = lower("${module.naming_mgt_alerts.full_name}-security-ar") # "ActivityLog-${each.key}"
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = local.platform_subs # Assign to platform subscriptions.  
  enabled             = var.activity_log_alerts.Security.enabled
  criteria {
    category = "Security"
    level    = try(var.activity_log_alerts.Security.level, null) # Define the severity levels ("Verbose", "Informational", "Warning", "Error", "Critical"). 
    statuses = var.activity_log_alerts.Security.statuses         # Define the status events ("Started", Failed", "Succeeded").
  }
  action {
    action_group_id = local.action_group_ids[var.activity_log_alerts["Security"].action_group]
  }
}

# Alerts: Resource Health
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  name                = lower("${module.naming_mgt_alerts.full_name}-resource-ar") # "ActivityLog-${each.key}"
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = local.platform_subs # Assign to platform subscriptions.  
  enabled             = var.activity_log_alerts.ResourceHealth.enabled
  criteria {
    category = "ResourceHealth"
    resource_health {
      current = try(var.activity_log_alerts.ResourceHealth.current, null) # Resource health alerts only. 
    }
  }
  action {
    action_group_id = local.action_group_ids[var.activity_log_alerts["ResourceHealth"].action_group]
  }
}

# Alerts: Service Health 
resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = lower("${module.naming_mgt_alerts.full_name}-service-ar") # "ActivityLog-${each.key}"
  resource_group_name = azurerm_resource_group.mgt_alerts.name
  location            = "global" # Resources are only supported in the following regions: [global, westeurope, northeurope, eastus2euap]. 
  tags                = local.tags_merged
  scopes              = local.platform_subs # Assign to platform subscriptions.  
  enabled             = var.activity_log_alerts.ServiceHealth.enabled
  criteria {
    category = "ServiceHealth"
    service_health {
      events    = try(var.activity_log_alerts.ServiceHealth.events, null) # Service alerts only. 
      locations = try(var.activity_log_alerts.ServiceHealth.locations, null)
    }
  }
  action {
    action_group_id = local.action_group_ids[var.activity_log_alerts["ServiceHealth"].action_group]
  }
}
