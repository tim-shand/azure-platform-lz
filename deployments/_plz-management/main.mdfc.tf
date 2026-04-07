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
  for_each     = local.active_subscriptions # Enable for all active subscriptions. 
  scope        = each.value.id              # Assign to each subscription.
  workspace_id = azurerm_log_analytics_workspace.mgt.id
}

# Defender for Cloud (CSPM): Virtual Machines
resource "azurerm_security_center_subscription_pricing" "cspm" {
  for_each      = toset(local.mdfc_cspm_resources_enabled) # Only create if CSPM is enabled, and each resource is enabled.
  tier          = "Standard"
  resource_type = each.value
}
