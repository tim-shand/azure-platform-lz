terraform {
  required_version = "~> 1.15.0"
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
    github = {
      source  = "integrations/github"
      version = "~> 6.11.0"
    }
  }
}
provider "random" {}  # Used to generate random strings and values.
provider "azuread" {} # Tenant ID is read from environment variable 'ARM_TENANT_ID' in workflow.
provider "azurerm" {
  features {}
  tenant_id           = data.azuread_client_config.current.tenant_id # Get tenant ID from 'azuread' provider. 
  subscription_id     = var.subscription_id                          # Target subscription ID for stack resource deployment. 
  storage_use_azuread = true                                         # Force Entra ID for authentication to Storage services. 
}
provider "github" {} # GitHub provider taps into GitHub CLI authentication, where it picks up the token issued by `gh auth login` command.
