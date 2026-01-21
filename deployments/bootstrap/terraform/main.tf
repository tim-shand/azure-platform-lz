#=====================================================#
# Platform LZ: Bootstrap - Main
#=====================================================#

# Get data for existing GitHub Repository.
data "github_repository" "repo" {
  full_name = "${var.global.repo_config.org}/${var.global.repo_config.repo}"
}

# Deployment Naming ----------------------------------------------------|
# Generate uniform, consistent name outputs to be used with resources.  
module "naming_bootstrap" {
  source   = "../../../modules/global-naming"
  sections = [var.global.naming.org_code, var.naming.stack_code]
}
