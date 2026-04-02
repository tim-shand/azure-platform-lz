locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Filter active subscriptions only.
  active_subscriptions = {
    for sub in data.azurerm_subscriptions.all.subscriptions :
    sub.subscription_id => sub
    if sub.state == "Enabled"
  }
}

locals {
  # Define list of resources to enable for MDfC CSPM.
  mdfc_cspm_resources_enabled = [
    for k, v in var.mdfc_cspm_resources : k
    if v == true && var.mdfc_enable_defender_cspm == true
  ]
}
