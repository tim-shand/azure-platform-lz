terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
  #backend "azurerm" {} # Use backend supplied during workflow. 
}
provider "azurerm" {
  features {}
  tenant_id           = data.azuread_client_config.current.tenant_id # Get from current session. 
  subscription_id     = var.subscription_id                          # Provided by workflow variable. 
  storage_use_azuread = true                                         # Use Entra ID only for interacting with Storage services. 
}

data "azuread_client_config" "current" {} # Get current user session data.
data "azurerm_subscription" "current" {}  # Get current Azure subscription.
