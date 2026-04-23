terraform {
  required_version = "~> 1.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.65.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.0"
    }
  }
  backend "azurerm" {}
}

provider "random" {}
provider "azuread" {} # Tenant ID is read from environment variable 'ARM_TENANT_ID' in workflow.

# Primary provider for AzureRM - target subscription.
provider "azurerm" {
  features {}
  tenant_id           = data.azuread_client_config.current.tenant_id # Get tenant ID from current session. 
  subscription_id     = var.subscription_id                          # Target subscription ID for stack resources. 
  storage_use_azuread = true                                         # Use Entra ID only for interacting with Storage services. 
}

# Secondary alias "iac" for accessing remote backend states of other stacks.
provider "azurerm" {
  alias = "iac"  
  features {}
  tenant_id           = data.azuread_client_config.current.tenant_id # Get tenant ID from current session. 
  subscription_id     = var.subscription_id_iac                      # Use dedicated IaC subscription (pass in from workflow).
  storage_use_azuread = true                                         # Use Entra ID only for interacting with Storage services. 
}
