#=================================================================#
# Identity: Azure - Global Outputs
#=================================================================#

# Data: Global Outputs - Used to stored details on global shared services. 
data "azurerm_key_vault" "globals_kv" {
  name                = var.global_outputs_kv.name
  resource_group_name = var.global_outputs_kv.resource_group
}

# Global Outputs: Stored in Key Vault
resource "azurerm_key_vault_secret" "gov_uai_policy_deployer_pid" {
  name         = "gov_uai_policy_deployer_pid"
  value        = azurerm_user_assigned_identity.policy_deployer.principal_id
  key_vault_id = data.azurerm_key_vault.globals_kv
}
