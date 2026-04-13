#====================================================================================#
# Identity: Entra ID Groups
# Description: 
# - Create groups in Entra ID for privilaged administrator RBAC roles. 
# - Create groups in Entra ID for user/team standard access RBAC roles.   
#====================================================================================#

# Entra ID: Groups [ADMIN] - Create per definition in TFVARS. 
resource "azuread_group" "grp_adm" {
  for_each = {
    for k, v in var.entra_groups_admins :
    k => v
    if v.active == true # Only create groups that are set to be active. 
  }
  display_name = "${var.entra_groups_admins_prefix}${each.key}" # GRP_ADM_NetworkAdmins
  description  = each.value.description
  owners = [
    data.azuread_user.group_owners_adm[each.key].object_id # Group owner lookup using employee ID. 
  ]
  security_enabled        = true # At least one of security_enabled or mail_enabled must be specified.  
  prevent_duplicate_names = true # Return an error if an existing group is found with the same name. 
}

# Diagnostic Settings: Entra ID - Logging
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting
resource "azurerm_monitor_aad_diagnostic_setting" "main" {
  name                       = "mgt-diag-entra-logs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.mgt_logs.id
  dynamic "enabled_log" {
    for_each = local.entraid_log_types_enabled # Loop dynamic for each enabled category log type. 
    content {
      category = enabled_log.key # Must use name of dynamic object as the "each". 
    }
  }
}
