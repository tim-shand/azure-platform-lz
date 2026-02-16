#====================================================================================#
# Management: Managed Identity
# Description: 
# - Create User-Assigned Managed Identity.
# - Used to deploy Diagnostic Settings to resources via Policy Assignment. 
#====================================================================================#

# Managed Identity (User-Assigned)
resource "azurerm_user_assigned_identity" "diag" {
  name                = "${module.naming_mgt_logs.full_name}-deploy-mi"
  resource_group_name = azurerm_resource_group.mgt_logs.name
  location            = azurerm_resource_group.mgt_logs.location
  tags                = local.tags_merged
}

# RBAC: Monitoring Contributor
resource "azurerm_role_assignment" "rbac_diag_mi" {
  scope                = data.azurerm_app_configuration_key.mg_core_id.value # Assign at core management group.
  role_definition_name = "Monitoring Contributor"                            # Required to modify diagnostic settings on resources. 
  principal_id         = azurerm_user_assigned_identity.diag.principal_id    # Assign to User-Assigned Managed Identity. 
}
