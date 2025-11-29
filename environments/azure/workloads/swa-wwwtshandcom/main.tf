#=================================================#
# Workload: Personal Website (www.tshand.com)
#=================================================#

# Type: Azure Static Web App, Key Vault
# Deployment: GitHub Actions

# Know Issues:
# - Intermitent 404 errors after creation. 
#   - Docs: https://learn.microsoft.com/en-us/answers/questions/5573452/intermittent-404-response-on-static-web-apps-via-c

# Use IaC Backend vending to generate 'prd' and 'dev' GitHub envrionments. 
# Deploy workload with GitHub actions, manually selecting the environment, or defaulting to 'dev' for auto-triggered. 
# Static Web App deployment token is stored in Azure Key Vault within the workloads Resource Group. 

module "swa-tshand-com" {
  source            = "../../../../modules/azure/swa-webapp-basic-dns"
  location          = var.location
  subscription_id   = var.subscription_id
  naming            = var.naming
  tags              = var.tags
  swa_config        = var.swa_config
  cloudflare_config = var.cloudflare_config
  project_groups    = var.project_groups
}
