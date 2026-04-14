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
resource "azurerm_security_center_workspace" "mgt" {
  for_each = var.enable_resource_deployment.defender_for_cloud ? local.active_subscriptions : {}
  scope        = each.value.id              # Assign to each subscription.
  workspace_id = azurerm_log_analytics_workspace.mgt[0].id
}

# Defender for Cloud (CSPM): Virtual Machines
# Only create if CSPM is enabled, and each resource is enabled.
resource "azurerm_security_center_subscription_pricing" "cspm" {
  for_each = var.enable_resource_deployment.defender_for_cloud ? toset(local.mdfc_cspm_resources_enabled) : []
  tier          = "Standard"
  resource_type = each.value
}
