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
      "Microsoft.AppConfiguration/*",
      "Microsoft.AppConfiguration/configurationStores/*",
      "Microsoft.KeyVault/*",
      "Microsoft.Storage/*",
      "Microsoft.Network/*",
      # Resource Groups
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      # Management Groups
      "Microsoft.Management/managementGroups/*",
      # Policy
      "Microsoft.Authorization/policyAssignments/*",
      "Microsoft.Authorization/policyDefinitions/*",
      "Microsoft.Authorization/policySetDefinitions/*",
      "Microsoft.Authorization/policyExemptions/*",
      "Microsoft.PolicyInsights/*",
      # RBAC
      "Microsoft.Authorization/locks/*",
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/read",
      # Monitoring
      "Microsoft.Insights/*",
      "Microsoft.OperationalInsights/*",
      "Microsoft.OperationsManagement/*",
      # Managed Identities
      "Microsoft.ManagedIdentity/*",
      # Security
      "Microsoft.Security/*",
      # Entra ID
      "Microsoft.AADIAM/diagnosticSettings/*"
    ]
    not_actions = [
      "Microsoft.Authorization/elevateAccess/Action",
    ]
    data_actions = [] # Role assignments to Management Groups can not be made to custom role definitions with DataActions. 
  }
}
