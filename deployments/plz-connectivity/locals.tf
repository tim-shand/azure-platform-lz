# CONNECTIVITY: General
# ------------------------------------------------------------- #

locals {
  tags_merged = merge(var.global.tags, var.stack.tags) # Merge global tags with stack tags. 
}

locals {
  hub_services_enabled = {
    for k, v in var.hub_services :
    k => {
      enabled                = v.enabled
      subnet                 = v.subnet
      subnet_outbound_access = v.subnet_outbound_access # Disable default outbound internet access to force via gateway.
    }
    if v.enabled == true # Only select enabled subnets. 
  }
}
