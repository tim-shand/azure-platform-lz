locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Log Analytics from MGT stack.
  mgt_law_workspace = data.terraform_remote_state.mgt.outputs.log_analytics_workspace

  # Storage Account from MGT stack.
  mgt_storage_account = data.terraform_remote_state.mgt.outputs.storage_account
}

locals {
  # Map enabled hub services. 
  hub_services_enabled = {
    for k,v in var.hub_services :
    k => v
    if v.enabled
  }
}

