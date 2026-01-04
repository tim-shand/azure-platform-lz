#=================================================================#
# Vending: Azure IaC Backends
#=================================================================#

module "plz-vending-backend" {
  for_each                 = var.projects # Repeat for all listed in terraform.tfvars
  source                   = "../../modules/plz-vending-backend"
  iac_storage_account_rg   = var.iac_storage_account_rg   # Name of Resource Group that holds IaC Backend Storage Account. 
  iac_storage_account_name = var.iac_storage_account_name # Name of Storage Account that holds IaC Backend state files. 
  github_config            = var.github_config            # Map of GitHub repository details. 
  project_name             = each.key                     # Prefixed with "tfstate": tfstate-plz-governance
  create_github_env        = each.value.create_github_env # Create GitHub environment for stack. 
}
