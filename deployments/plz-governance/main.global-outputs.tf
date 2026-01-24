#=================================================================#
# Governance: Azure - Global Outputs
#=================================================================#

# Used to contain resource IDs, names, and other data required by other stacks/deployments. 

# Data: Global Outputs - Used to stored details on global shared services. 
data "azurerm_key_vault" "globals_kv" {
  name                = var.global_outputs_kv.name
  resource_group_name = var.global_outputs_kv.resource_group
}

# Global Outputs: Stored in Key Vault
resource "azurerm_key_vault_secret" "iac_mg_root" {
  name         = "ServicePrincipal-IaC-Deploy"
  value        = module.management_groups.root_id
  key_vault_id = data.azurerm_key_vault.globals_kv
}
