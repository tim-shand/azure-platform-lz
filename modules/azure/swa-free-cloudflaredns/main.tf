#======================================#
# Module: Static Web App - Main
#======================================#

# Data Calls
data "azuread_client_config" "current" {}

# Generate naming conventions.
# Generate a random integer to use for suffix uniqueness.

locals {
  # Default Names
  name_full  = "${var.naming.prefix}-${var.naming.service}-${var.naming.project}-${var.swa_config.environment}"
  name_short = "${var.naming.prefix}${var.naming.service}${var.naming.project}${var.swa_config.environment}"
  # Key Vault
  kv_name_max_length = 24 # Random integer suffix will add 5 chars, so max = 19 for base name.
  kv_name_base       = "${local.name_short}kv${random_integer.rndint.result}"
  kv_name            = length(local.kv_name_base) > local.kv_name_max_length ? "${substr(local.kv_name_base, 0, local.kv_name_max_length - 5)}${random_integer.rndint.result}" : local.kv_name_base
}

# Generate a random integer to use for suffix uniqueness.
resource "random_integer" "rndint" {
  min = 10000
  max = 99999
}

# Merge environment tags with default tags. 

# Azure: Static Web App ==============================================#
# Resource group for the project.
resource "azurerm_resource_group" "swa_rg" {
  name     = "${local.name_full}-rg"
  location = var.location
  tags     = var.tags
}

# Azure: Static Web App
resource "azurerm_static_web_app" "swa" {
  name                = "${local.name_full}-swa"
  resource_group_name = azurerm_resource_group.swa_rg.name
  location            = azurerm_resource_group.swa_rg.location
  tags                = var.tags
  sku_tier            = "Free" # or "Standard"
  repository_url      = var.swa_config.gh_repo_url
  repository_branch   = var.swa_config.gh_repo_branch
}

# Azure: Key Vault - Used to store SWA deployment token.
resource "azurerm_key_vault" "swa_keyvault" {
  name                       = local.kv_name
  resource_group_name        = azurerm_resource_group.swa_rg.name
  location                   = azurerm_resource_group.swa_rg.location
  tags                       = var.tags
  tenant_id                  = data.azuread_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
}

# Azure: Key Vault - RBAC Assignments
data "azuread_group" "project_groups" {
  for_each     = toset(var.project_groups)
  display_name = each.value
}
resource "azurerm_role_assignment" "rbac_kv" {
  for_each             = data.azuread_group.project_groups # Repeat for each Entra group provided by data call.
  scope                = azurerm_key_vault.swa_keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value.object_id # Obtained from data call, loop. 
}

# Azure: Key Vault - Create Secret (SWA Deployment Token)
resource "azurerm_key_vault_secret" "swa_token" {
  name         = "DeploymentToken-${var.naming.project}-${var.swa_config.environment}"
  value        = azurerm_static_web_app.swa.api_key # Used by source repo for deployment via GHA.
  key_vault_id = azurerm_key_vault.swa_keyvault.id
}

# Cloudflare: DNS ==============================================#
# Add auto-generated SWA DNS name as CNAME record for custom domain check."
resource "cloudflare_dns_record" "cname_record" {
  count   = var.swa_config.enable_cloudflare_dns ? 1 : 0 # Only setup DNS resources if enabled.
  zone_id = var.cloudflare_config["zone_id"]
  name    = var.swa_config.custom_domain_name
  ttl     = 300                                                                                 # 60 seconds, can update later on.
  type    = "CNAME"                                                                             # Can be "A" or "TXT" depending on your setup.
  comment = "Azure - ${var.naming.project}-${var.swa_config.environment} - Domain Verification" # Adds a comment for clarity.
  content = azurerm_static_web_app.swa.default_host_name                                        # Supplied by Azure SWA resource after creation.
  proxied = false                                                                               # Required to be 'false' for DNS CNAME verification.
}

# Sleep while DNS propagates (it can take a few minutes).
resource "time_sleep" "wait_for_dns" {
  count           = var.swa_config.enable_cloudflare_dns ? 1 : 0 # Only setup DNS resources if enabled.
  create_duration = "180s"
  depends_on = [
    cloudflare_dns_record.cname_record
  ]
}

# Azure: Add custom domain to SWA, after waiting for DNS.
resource "azurerm_static_web_app_custom_domain" "swa_domain" {
  count             = var.swa_config.enable_cloudflare_dns ? 1 : 0 # Only setup DNS resources if enabled.
  static_web_app_id = azurerm_static_web_app.swa.id
  domain_name       = var.swa_config.custom_domain_name
  validation_type   = "cname-delegation" # dns-txt-token
  depends_on = [
    time_sleep.wait_for_dns # Only deploy if this resource succeeds.
  ]
}
