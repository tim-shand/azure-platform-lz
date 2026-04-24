#====================================================================================#
# Management: Defender for Cloud
# Description: 
# - Configure Log Analytics Workspace for Security data. 
# - Deploy the CSPM plan (if enabled).
#====================================================================================#

# DEFENDER FOR CLOUD ------------------------------------------------------------------ #

# Microsoft Cloud Security Benchmark (MCSB) is free.
# Individual Defender plans (VMs, Storage, SQL) are paid and controlled by flag.

# Security Center: Send to Log Insights Workspace. 
# resource "azurerm_security_center_workspace" "mgt" {
#   # Intentionally scoped to all enabled tenant subscriptions, not just platform.
#   # MDFC security data is centralised into the platform LAW regardless of subscription ownership.
#   #for_each      = local.active_subscriptions
#   for_each      = toset(local.platform_subscription_scopes)
#   #scope        = each.value.id              # Assign to each subscription.
#   #scope         = "/subscriptions/${each.key}"
#   scope         = each.key
#   workspace_id  = azurerm_log_analytics_workspace.mgt.id
# }

resource "azapi_update_resource" "mdfc_workspace" {
  for_each    = local.active_subscriptions
  type        = "Microsoft.Security/workspaceSettings@2017-08-01-preview"
  resource_id = "/subscriptions/${each.key}/providers/Microsoft.Security/workspaceSettings/default"
  body = {
    properties = {
      scope       = "/subscriptions/${each.key}"
      workspaceId = azurerm_log_analytics_workspace.mgt.id
    }
  }
}

# Security Center: Contact Details
resource "azurerm_security_center_contact" "mgt" {
  name  = var.action_groups.security.name
  email = var.action_groups.security.email
  alert_notifications = var.mdfc_alerts.alert_notifications # Send security alerts notifications to the security contact.
  alerts_to_admins    = var.mdfc_alerts.alerts_to_admins    # Send security alerts notifications to subscription admins.

}

# Defender for Cloud (CSPM): Virtual Machines
# Only create if CSPM is enabled, and each resource is enabled.
resource "azurerm_security_center_subscription_pricing" "cspm" {
  for_each      = toset(local.mdfc_cspm_resources_enabled)
  tier          = "Standard"
  resource_type = each.value
}
