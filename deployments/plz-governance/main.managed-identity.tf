#====================================================================================#
# Governance: Managed Identity
# Description: 
# - Create User-Assigned Managed Identity for identity reuse and centralized governance.
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
  name                = module.naming_policy_mi.user_assigned_managed_identity
  resource_group_name = azurerm_resource_group.gov.name
  location            = azurerm_resource_group.gov.location
  tags                = local.tags_merged
}

# RBAC: Monitoring Contributor
resource "azurerm_role_assignment" "rbac_policy_mi" {
  for_each             = toset(local.policy_managed_identity_roles)         # Defined in locals.tf file.
  scope                = data.azurerm_management_group.core.id              # Assign at core management group.
  principal_id         = azurerm_user_assigned_identity.policy.principal_id # Assign to User-Assigned Managed Identity. 
  role_definition_name = each.value
}
