terraform {
  required_version = "~> 1.14.0"
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
}

provider "azurerm" {
  features {}
  tenant_id           = data.azuread_client_config.current.tenant_id # Get tenant ID from current session. 
  subscription_id     = var.subscription_id                          # Provided by workflow variable, or terminal input. 
  storage_use_azuread = true                                         # Use Entra ID for interacting with Storage services (when shared keys disabled). 
}

data "azuread_client_config" "current" {} # Get current user session data. 
data "azurerm_subscription" "current" {}  # Get current Azure subscription. 
