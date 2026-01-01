terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.7.5"
    }
  }
}
