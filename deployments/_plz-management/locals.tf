locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)
}

locals {
  # Flat list of locations. 
  locations_all = flatten([ # Flatten the map of strings and list (approved) into a single list.
    var.global.location.primary,
    var.global.location.secondary
  ])
}

locals {
  # Filter all active subscriptions.
  active_subscriptions = {
    for sub in data.azurerm_subscriptions.all.subscriptions :
    sub.subscription_id => sub
    if sub.state == "Enabled"
  }

  # Flatten list of platform subscription IDs from remote bootstrap state and remove any duplicates.
  platform_subscription_ids = tolist(toset(values(
    data.terraform_remote_state.iac.outputs.platform_subscription_ids
  )))

  # Build list of subscription objects using platform subscription ID list. 
  # platform_subscriptions = [
  #   for sub in data.azurerm_subscriptions.all.subscriptions : sub
  #   if contains(local.platform_subscription_ids, sub.subscription_id)
  # ]
  platform_subscriptions = {
    for sub in data.azurerm_subscriptions.all.subscriptions :
    sub.subscription_id => sub
    if contains(local.platform_subscription_ids, sub.subscription_id)
  }
}

locals {
  # Define list of resources to enable for MDfC CSPM.
  mdfc_cspm_resources_enabled = [
    for k, v in var.mdfc_cspm_resources : k
    if v == true && var.mdfc_enable_defender_cspm == true
  ]
}

locals {
  # Convert list of resource types into a single wildcard string for resource_id.
  alert_deletion_resource_id = "/subscriptions/*/providers/{${join(",", var.alert_on_resource_deletion)}}/*"
}
