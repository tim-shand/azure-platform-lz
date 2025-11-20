#=================================================#
# Platform: Deploying Azure Platform Landing Zone.
#=================================================#

# Deploy resources via modules. 

module "plz-gov-management-groups" {
  source = "../../../modules/azure/plz-gov-management-groups"
  plz_management_groups = var.plz_management_groups
  naming                = var.naming
  subscription_ids_plz  = var.subscription_ids_plz # Passed in via GH workflow.
}


# module "plz-con-network-hub" {
#   source = "../../../modules/plz-con-network-hub"
#   for_each = var.enable_plz_hubvnet ? { "hub" = true } : {}
#   location = var.location # Get from TFVARS file.
#   naming = var.naming # Get from TFVARS file.
#   tags = var.tags # Get from TFVARS file.
#   vnet_space = "10.50.0.0/22" # Allows 4x /24 subnets.
#   subnet_space = "10.50.0.0/24" # Default subnet address space.
# }

# module "plz-log-monitor-diagnostics" {
#   source = "../../../modules/plz-log-monitor-diagnostics"
#   for_each = var.enable_plz_logging ? { "log" = true } : {}
#   location = var.location # Get from TFVARS file.
#   naming = var.naming # Get from TFVARS file.
#   tags = var.tags # Get from TFVARS file.
# }
