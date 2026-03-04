# CONNECTIVITY: General
# ------------------------------------------------------------- #

locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

# Hub VNet: Subnets (enabled).
locals {
  hub_subnets_enabled = {
    for k, v in var.vnet_hub_subnets :
    k => v
    if v.enabled == true # Only select enabled subnets. 
  }
}
