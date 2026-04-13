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
}
provider "random" {}
provider "azurerm" {
  features {}
  tenant_id           = data.azuread_client_config.current.tenant_id # Get tenant ID from current session. 
  subscription_id     = var.subscription_id                          # Target subscription ID for stqack resources. 
  storage_use_azuread = true                                         # Use Entra ID only for interacting with Storage services. 

}
data "azuread_client_config" "current" {} # Get current user session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.
