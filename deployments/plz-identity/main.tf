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
    if v.Active == true # Only create groups that are set to be active. 
  }
  display_name = "${var.entra_groups_admins_prefix}${each.key}" # GRP_ADM_NetworkAdmins
  description  = each.value.Description
  owners = [
    azuread_group.grp_adm["PlatformAdmins"].object_id # Group owner. 
  ]
  security_enabled        = true # At least one of security_enabled or mail_enabled must be specified.  
  prevent_duplicate_names = true # Return an error if an existing group is found with the same name. 
}

# Entra ID: Groups [USER] - Create per definition in TFVARS. 
resource "azuread_group" "grp_usr" {
  for_each = {
    for k, v in var.entra_groups_users :
    k => v
    if v.Active == true # Only create groups that are set to be active. 
  }
  display_name = "${var.entra_groups_users_prefix}${each.key}" # GRP_ADM_NetworkAdmins
  description  = each.value.Description
  owners = [
    azuread_group.grp_adm["PlatformAdmins"].object_id # Group owner. 
  ]
  security_enabled        = true # At least one of security_enabled or mail_enabled must be specified.  
  prevent_duplicate_names = true # Return an error if an existing group is found with the same name. 
}

# ------------------------------------------------------------- #
