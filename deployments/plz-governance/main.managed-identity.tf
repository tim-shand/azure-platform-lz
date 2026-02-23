#====================================================================================#
# Governance: Managed Identity
# Description: 
# - Create User-Assigned Managed Identity.
# - Used to deploy policy configuration to resources via Policy Assignment. 
#====================================================================================#

# Naming: Generate naming convention, pre-determined values and format. 
module "naming_policy_mi" {
  source       = "../../modules/global-resource-naming"
  prefix       = var.global.naming.org_prefix
  workload     = var.stack.naming.workload_code # Management Group key names. 
  stack_or_env = "policy"                       # Static suffix for Management Groups. 
}

# Managed Identity (User-Assigned)
resource "azurerm_user_assigned_identity" "policy" {
  name                = "${module.naming_policy_mi.full_name}-deploy-mi"
  resource_group_name = azurerm_resource_group.gov.name
  location            = azurerm_resource_group.gov.location
  tags                = local.tags_merged
}

# RBAC: Monitoring Contributor
resource "azurerm_role_assignment" "rbac_policy_mi" {
  scope                = data.azurerm_app_configuration_key.mg_core_id.value # Assign at core management group.
  role_definition_name = "Monitoring Contributor"                            # Required to modify diagnostic settings on resources. 
  principal_id         = azurerm_user_assigned_identity.policy.principal_id  # Assign to User-Assigned Managed Identity. 
}
