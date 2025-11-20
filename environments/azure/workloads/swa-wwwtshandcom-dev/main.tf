#=================================================#
# Workload: Personal Website (www.tshand.com)
#=================================================#

module "swa-tshand-com" {
  source = "../../../../modules/azure/app-web-staticwebapp"
  location = var.location
  subscription_id = var.subscription_id
  naming = var.naming
  tags = var.tags
  custom_domain_name = var.custom_domain_name
  github_config = var.github_config
  cloudflare_config = var.cloudflare_config
}
