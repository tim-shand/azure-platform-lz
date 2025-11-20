#======================================#
# Module: Static Web App - Main
#======================================#

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.8.2"
    }
    # Used for GitHub resources, such as repositories, uploading secrets to Github Actions.
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Resource group for the project.
resource "azurerm_resource_group" "swa_rg" {
  name          = "${var.naming.prefix}-${var.naming.platform}-${var.naming.project}-${var.naming.environment}-rg"
  location      = var.location
  tags          = var.tags
}

# Azure: Static Web App
resource "azurerm_static_web_app" "swa" {
  name                  = "${var.naming.prefix}-${var.naming.platform}-${var.naming.project}-${var.naming.environment}-swa"
  resource_group_name   = azurerm_resource_group.swa_rg.name
  location              = azurerm_resource_group.swa_rg.location
  sku_tier              = "Free" # or "Standard"
  tags                  = var.tags
}

# Cloudflare: Add auto-generated SWA DNS name as CNAME record for custom domain check."
resource "cloudflare_dns_record" "cname_record" {
  zone_id       = "${var.cloudflare_config["zone_id"]}"
  name          = "${var.custom_domain_name}"
  ttl           = 60 # 60 seconds, can update later on.
  type          = "CNAME" # Can be "A" or "TXT" depending on your setup.
  comment       = "Azure - ${var.naming.project} - Domain verification record" # Adds a comment for clarity.
  content       = azurerm_static_web_app.swa.default_host_name # Supplied by Azure SWA resource after creation.
  proxied       = false # Required to be 'false' for DNS CNAME verification.
}

# Sleep while DNS propagates (it can take a few minutes).
resource "time_sleep" "wait_for_dns" {
  create_duration = "180s"
  depends_on      = [
    cloudflare_dns_record.cname_record
  ]
}

# Azure: Add custom domain to SWA, after waiting for DNS.
resource "azurerm_static_web_app_custom_domain" "swa_domain" {
  static_web_app_id = azurerm_static_web_app.swa.id
  domain_name       = "${var.custom_domain_name}"
  validation_type   = "cname-delegation" # dns-txt-token
  depends_on        = [
    time_sleep.wait_for_dns # Only deploy if this resource succeeds.
  ]
}

# GitHub Actions: Upload secret (deployment token) for the SWA.
resource "github_actions_secret" "swa_token" {
  repository      = var.github_config["src_repo"]
  secret_name     = "azure_swa_token_${var.naming.project}_${var.naming.environment}"
  plaintext_value = azurerm_static_web_app.swa.api_key
}
