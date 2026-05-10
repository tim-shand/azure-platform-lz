locals {
  # Merge global tags with stack tags.
  tags_merged = merge(var.global.tags, var.stack.tags)

  # Log Analytics from MGT stack.
  mgt_law_workspace = data.terraform_remote_state.mgt.outputs.log_analytics_workspace

  # Storage Account from MGT stack.
  mgt_storage_account = data.terraform_remote_state.mgt.outputs.storage_account
}

locals {
  bastion_features = {
    copy_paste_enabled        = var.hub_bastion.features.copy_paste_enabled
    # NOTE: The below options require 'Standard' SKU.
    file_copy_enabled         = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.file_copy_enabled
    tunneling_enabled         = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.tunneling_enabled
    shareable_link_enabled    = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.shareable_link_enabled
    kerberos_enabled          = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.kerberos_enabled
    ip_connect_enabled        = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.ip_connect_enabled
    session_recording_enabled = (var.hub_bastion.sku_tier == "Developer" || var.hub_bastion.sku_tier == "Basic") ? false : var.hub_bastion.features.session_recording_enabled
  }
}

locals {
  # Basic SKU gateway requires Basic public IP with Dynamic allocation and no zones.
  # All other SKUs require Standard public IP with Static allocation and zones.
  vpn_gateway_pip_sku        = var.hub_vpn.sku_tier == "Basic" ? "Basic" : "Standard"
  vpn_gateway_pip_allocation = var.hub_vpn.sku_tier == "Basic" ? "Dynamic" : "Static"
  vpn_gateway_pip_zones      = var.hub_vpn.sku_tier == "Basic" ? [] : ["1", "2", "3"]
}
