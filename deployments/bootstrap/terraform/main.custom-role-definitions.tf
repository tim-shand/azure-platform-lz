#====================================================================================#
# Bootstrap: Custom Role Definitions
# Description: 
# - Create custom role to be assigned to Service Principal. 
# - Allows a single role with multiple permissions on control plane. 
#====================================================================================#

# Custom Role: Create custom role to be assigned to Service Principal for multiple permissions on control and data plane. 
resource "azurerm_role_definition" "custom_role_iac_deploy" {
  name        = "Custom-IaC-Deploy"
  description = "Custom role for executing automation deployments using IaC service principal."
  scope       = data.azurerm_management_group.tenant_root.id
  permissions {
    actions = [
      # General resource control
      "Microsoft.Resources/*",
      "Microsoft.Resources/deployments/*",
      # App Configuration
      "Microsoft.AppConfiguration/*",
      "Microsoft.AppConfiguration/configurationStores/*",
      # Resource Groups
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      # Management Groups
      "Microsoft.Management/managementGroups/*",
      # Policy
      "Microsoft.Authorization/policyAssignments/*",
      "Microsoft.Authorization/policyDefinitions/*",
      "Microsoft.Authorization/policySetDefinitions/*",
      # RBAC
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/read",
      # Locks
      "Microsoft.Authorization/locks/*",
      # Monitoring
      "Microsoft.Insights/*",
      # Managed Identities
      "Microsoft.ManagedIdentity/*",
      # Entra ID
      "Microsoft.AADIAM/diagnosticSettings/*"
    ]
    not_actions = [
      "Microsoft.Authorization/elevateAccess/Action",
    ]
    data_actions = [] # Role assignments to Management Groups can not be made to custom role definitions with DataActions. 
  }
}
