# GLOBAL / SHARED SERVICES
# ------------------------------------------------------------- #

# IaC: Get IaC subscription for aliased provider. 
data "azurerm_subscription" "iac_sub" {
  subscription_id = var.subscription_id_iac # Pass in the IaC subscription variable. 
}

# Shared Services: Get App Configuration data using alias provider. 
data "azurerm_app_configuration" "iac" {
  provider            = azurerm.iac             # Use aliased provider to access IaC subscription. 
  name                = var.global_outputs_name # Pass in shared services App Configuration name via workflow variable. 
  resource_group_name = var.global_outputs_rg   # Pass in shared services App Configuration Resource Group name via workflow variable. 
}

# IDENTITY: General
# ------------------------------------------------------------- #

# [DISABLED - not required].
# Domain: Get the initial domain suffix to use for UPNs.  
# data "azuread_domains" "initial" {
#   only_initial = true # Only pull the initial domain (onmicrosoft.com). 
# }

# # Get the current default domain suffix to use for UPNs. 
# data "azuread_domains" "default" {
#   only_default = true # Only pull the default custom domain. 
# }
