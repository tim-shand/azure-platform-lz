# Deployment Naming ----------------------------------------------------|
# Generate uniform, consistent name outputs to be used with resources.  
module "naming_bootstrap" {
  source     = "../../../modules/global-resource-naming"
  org_prefix = var.global.naming.org_prefix
  project    = var.naming.stack_code
}
