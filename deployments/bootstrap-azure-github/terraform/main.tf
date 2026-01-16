

module "naming" {
  source      = "../../../modules/global-resource-naming"
  org_prefix  = var.global.naming.org_prefix
  project     = var.global.naming.project
  environment = var.global.naming.environment
  category1   = var.naming.stack_code
}

