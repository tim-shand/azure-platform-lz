#====================================================================================#
# Management: Entra ID Groups
# Description: 
# - Create groups in Entra ID for privilaged administrator RBAC roles.  
#====================================================================================#

# Entra ID: Groups [ADMIN] - Create per definition in TFVARS. 
resource "azuread_group" "grp_adm" {
  for_each = var.enable_resource_deployment.entra_id_privilaged_groups ? {
    for k, v in var.entra_groups_privilaged :
    k => v
    if v.active == true # Only create groups that are set to be active. 
  } : null
  display_name = "${var.entra_groups_prefix}${each.key}" # GRP_ADM_NetworkAdmins
  description  = each.value.description
  owners = [
    data.azuread_client_config.current.object_id # Current user object ID.
  ]
  security_enabled        = true # At least one of security_enabled or mail_enabled must be specified.  
  prevent_duplicate_names = true # Return an error if an existing group is found with the same name. 
}

# Diagnostic Settings: Entra ID - Logging
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting
# resource "azurerm_monitor_aad_diagnostic_setting" "mgt" {
#   name                       = "mgt-diag-entra-logs"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.mgt.id
#   dynamic "enabled_log" {
#     for_each = local.entraid_log_types_enabled # Loop dynamic for each enabled category log type. 
#     content {
#       category = enabled_log.key # Must use name of dynamic object as the "each". 
#     }
#   }
# }
