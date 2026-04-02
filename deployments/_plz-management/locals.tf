locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)
}

locals {
  # Define list of resources to enable for MDfC CSPM.
  mdfc_cspm_resources_enabled = [
    for k, v in var.mdfc_cspm_resources : k
    if v == true && var.mdfc_enable_defender_cspm == true
  ]
}
