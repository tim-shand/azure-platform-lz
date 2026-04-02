locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Filter active subscriptions only.
  active_subscriptions = {
    for sub in data.azurerm_subscriptions.all.subscriptions :
    sub.subscription_id => sub
    if sub.state == "Enabled"
  }

  # Flat list of locations. 
  locations_all = flatten([ # Flatten the map of strings and list (approved) into a single list.
    var.location.primary,
    var.location.secondary,
    var.location.approved
  ])
}

locals {
  # Define list of resources to enable for MDfC CSPM.
  mdfc_cspm_resources_enabled = [
    for k, v in var.mdfc_cspm_resources : k
    if v == true && var.mdfc_enable_defender_cspm == true
  ]
}
