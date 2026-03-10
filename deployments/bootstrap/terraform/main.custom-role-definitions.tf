#====================================================================================#
# Bootstrap: Custom Role Definitions
# Description: 
# - Create custom role to be assigned to Service Principal. 
# - Allows a single role with multiple permissions on control and data plane. 
#====================================================================================#

# Custom Role: Create custom role to be assigned to Service Principal for multiple permissions on control and data plane. 
resource "azurerm_role_definition" "custom_role_iac_deploy" {
  name        = "Custom-IaC-Deploy"
  description = "Custom role for executing automation deployments using IaC service principal."
  scope       = azurerm_management_group.core.id # Assign at core management group level. 
  permissions {
    actions = [
      # General resource control
      "Microsoft.Resources/*",
      "Microsoft.Resources/deployments/*",
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
      "Microsoft.Insights/*"
    ]
    not_actions = [
      "Microsoft.Authorization/elevateAccess/Action",
      "Microsoft.Blueprint/blueprintAssignments/write",
      "Microsoft.Blueprint/blueprintAssignments/delete",
      "Microsoft.Purview/consents/delete",
    ]
    data_actions = [
      # App Configuration
      "Microsoft.AppConfiguration/configurationStores/*",
      # Key Vault
      "Microsoft.KeyVault/vaults/*",
      "Microsoft.KeyVault/vaults/secrets/*",
      # Storage Account
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/*",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/*",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/*"
    ]
  }
}
