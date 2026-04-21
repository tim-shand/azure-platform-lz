#====================================================================================#
# Management: Entra ID Groups
# Description: 
# - Create groups in Entra ID for privilaged administrator RBAC roles.
# - Assign RBAC roles per Entra ID privilaged group.
#====================================================================================#

# ENTRA ID: Groups -------------------------------------------------------------- #

# Entra ID: Groups [ADMIN] - Create per definition in TFVARS. 
resource "azuread_group" "grp_adm" {
  for_each = local.entra_groups_privilaged_enabled
  display_name = "${var.entra_groups_prefix}${each.key}" # GRP_ADM_NetworkAdmins
  description  = each.value.description
  owners = [
    data.azuread_client_config.current.object_id # Current user object ID.
  ]
  security_enabled        = true # At least one of security_enabled or mail_enabled must be specified.  
  prevent_duplicate_names = true # Return an error if an existing group is found with the same name. 
}

# RBAC ----------------------------------------------------------------------- #

# Create a deterministic GUID to avoid duplicates and guarantee uniqueness.
resource "random_uuid" "uuid" {}

# # RBAC: Assign Entra ID privilaged groups to roles. 
# resource "azurerm_role_assignment" "rbac_sp_builtin" {
#   for_each = local.entra_groups_privilaged_enabled
#   name = uuidv5(random_uuid.uuid.result, each.key)
#   scope                = azurerm_resource_group.iac.id              # Backend Resource Group.
#   role_definition_name = each.value                                 # Each RBAC role. 
#   principal_id         = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
#   principal_type       = "ServicePrincipal"                         # Avoids Azure RBAC graph lookup delays that sometimes break CI/CD pipelines.
# }

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
