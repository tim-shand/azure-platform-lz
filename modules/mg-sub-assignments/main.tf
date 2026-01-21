#=====================================================#
# Platform LZ: Governance - Management Groups
#=====================================================#

# Governance: Management Groups -----------------#
data "azurerm_subscriptions" "all" {} # Get all subscriptions visible to current user or Service Principal. 

locals {
  # Map matching subscriptions to management groups based on first three segments of the subscription ID. 
  management_group_subscriptions = {
    platform = [
      for s in data.azurerm_subscriptions.all.subscriptions : s.subscription_id
      if contains(var.subscription_prefixes.platform, join("-", slice(split("-", s.subscription_id), 0, 3)))
    ]
    workloads_prd = [
      for s in data.azurerm_subscriptions.all.subscriptions : s.subscription_id
      if contains(var.subscription_prefixes.workloads_prd, join("-", slice(split("-", s.subscription_id), 0, 3)))
    ]
    workloads_dev = [
      for s in data.azurerm_subscriptions.all.subscriptions : s.subscription_id
      if contains(var.subscription_prefixes.workloads_dev, join("-", slice(split("-", s.subscription_id), 0, 3)))
    ]
    sandbox = [
      for s in data.azurerm_subscriptions.all.subscriptions : s.subscription_id
      if contains(var.subscription_prefixes.sandbox, join("-", slice(split("-", s.subscription_id), 0, 3)))
    ]
    decommissioned = [
      for s in data.azurerm_subscriptions.all.subscriptions : s.subscription_id
      if contains(var.subscription_prefixes.decommissioned, join("-", slice(split("-", s.subscription_id), 0, 3)))
    ]
  }
}

# Management Groups: Top-level management group for the organisation.
resource "azurerm_management_group" "root" {
  name         = lower("${var.naming.org_prefix}-${var.management_group_root}-mg") # Force lower-case for resource name.
  display_name = var.management_group_root
}

# Management Groups: Level 1 -----------------------------------|
resource "azurerm_management_group" "platform" {
  name                       = lower("${var.naming.org_prefix}-platform-mg") # Force lower-case for resource name.
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.root.id              # Nested under root management group. 
  subscription_ids           = local.management_group_subscriptions.platform # Assign mapped subscriptions. 
}

resource "azurerm_management_group" "sandbox" {
  name                       = lower("${var.naming.org_prefix}-sandbox-mg") # Force lower-case for resource name.
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.root.id             # Nested under root management group. 
  subscription_ids           = local.management_group_subscriptions.sandbox # Assign mapped subscriptions.
}

resource "azurerm_management_group" "decommissioned" {
  name                       = lower("${var.naming.org_prefix}-decommissioned-mg") # Force lower-case for resource name.
  display_name               = "Decommissioned"
  parent_management_group_id = azurerm_management_group.root.id                    # Nested under root management group. 
  subscription_ids           = local.management_group_subscriptions.decommissioned # Assign mapped subscriptions.
}

resource "azurerm_management_group" "workloads" {
  name                       = lower("${var.naming.org_prefix}-workloads-mg") # Force lower-case for resource name.
  display_name               = "Workloads"
  parent_management_group_id = azurerm_management_group.root.id # Nested under root management group. 
}

# Management Groups: Level 2 -----------------------------------|
resource "azurerm_management_group" "workloads_prd" {
  name                       = lower("${var.naming.org_prefix}-production-mg") # Force lower-case for resource name.
  display_name               = "Production"
  parent_management_group_id = azurerm_management_group.workloads.id              # Nested under workloads management group. 
  subscription_ids           = local.management_group_subscriptions.workloads_prd # Assign mapped subscriptions.
}

resource "azurerm_management_group" "workloads_dev" {
  name                       = lower("${var.naming.org_prefix}-development-mg") # Force lower-case for resource name.
  display_name               = "Development"
  parent_management_group_id = azurerm_management_group.workloads.id              # Nested under workloads management group. 
  subscription_ids           = local.management_group_subscriptions.workloads_dev # Assign mapped subscriptions.
}
