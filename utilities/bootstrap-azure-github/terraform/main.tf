#=================================================================#
# Azure Bootstrap: Main
# Creates: 
# - Service Principal, Federated Credentials (OIDC) for IaC.
# - GitHub repository secrets and variables.
# - Resources for remote state backends (dedicated subscription).
#=================================================================#

# Set default naming conventions.
# locals {
#   resource_group_name    = "${var.naming["prefix"]}-${var.naming["service"]}-${var.naming["project"]}-${var.naming["environment"]}-rg"
#   service_principal_name = "${var.naming["prefix"]}-${var.naming["service"]}-${var.naming["project"]}-deploy-sp"
#   # Naming: Dynamically truncate string to a specified maximum length (max 24 chars for Storage Account naming).
#   sa_name_max_length    = 24 # Random integer suffix will add 5 chars, so max = 19 for base name.
#   sa_name_random_length = 5  # Number of random characters to add to storage account name. 
#   sa_name_base          = "${var.naming["prefix"]}${var.naming["service"]}${var.naming["project"]}sa${random_integer.rndint.result}"
#   # If the full length Storage Account name is greater than max allowed, trim it down to max length minus 5 characters, then add random number. 
#   sa_name_final = length(local.sa_name_base) > local.sa_name_max_length ? "${substr(local.sa_name_base, 0, local.sa_name_max_length - 5)}${random_integer.rndint.result}" : local.sa_name_base
# }

#=====================================================================#
# Azure: Entra ID
# Requires: 
# - Service Principal: [MSGraph: Application.ReadWrite.All]
# Info: https://learn.microsoft.com/en-us/graph/permissions-reference
#=====================================================================#





#=================================================================#
# Azure: Backend Resources
#=================================================================#

# Generate a random integer to use for suffix uniqueness.
# resource "random_integer" "rndint" {
#   min = 10000
#   max = 99999
# }

# Resource Group.
# resource "azurerm_resource_group" "iac_rg" {
#   name     = local.resource_group_name
#   location = var.location
#   tags     = var.tags
# }

# Storage Account.
# resource "azurerm_storage_account" "iac_sa" {
#   name                       = local.sa_name_final
#   resource_group_name        = azurerm_resource_group.iac_rg.name
#   location                   = azurerm_resource_group.iac_rg.location
#   account_tier               = "Standard"
#   account_replication_type   = "LRS"
#   account_kind               = "StorageV2"
#   tags                       = var.tags
#   https_traffic_only_enabled = true # Enforce secure file transfer. 
#   lifecycle {
#     precondition {
#       condition     = length(local.sa_name_final) < local.sa_name_max_length
#       error_message = "Storage Account must be less than 24 characters total."
#     }
#   }
# }

# # Storage Account Blob Container.
# resource "azurerm_storage_container" "iac_sa_cn" {
#   name                  = "tfstate-${var.naming["service"]}-bootstrap"
#   storage_account_id    = azurerm_storage_account.iac_sa.id
#   container_access_type = "private"
# }

# # RBAC: Assign 'Storage Data Contributor' role for current user.
# resource "azurerm_role_assignment" "rbac_sa_cu" {
#   scope                = azurerm_storage_account.iac_sa.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = data.azuread_client_config.current.object_id
# }

# # RBAC: Assign 'Storage Data Contributor' role for SP.
# resource "azurerm_role_assignment" "rbac_sa_sp" {
#   scope                = azurerm_storage_account.iac_sa.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azuread_service_principal.entra_iac_sp.object_id
# }
