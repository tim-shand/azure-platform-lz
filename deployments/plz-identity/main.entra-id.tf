#=====================================================#
# Platform LZ: Identity - Entra ID
#=====================================================#

# Naming: Generate uniform, consistent name outputs to be used with resources. 
module "naming_identity" {
  source        = "../../modules/global-naming"
  sections      = [var.global.naming.org_code, var.global.naming.project_name, var.global.naming.environment, var.naming.stack_code]
  append_random = true # Required for Key Vaults. 
}

# Entra ID: Groups (Default)
resource "azuread_group" "default" {
  for_each         = var.entra_groups # For each group defined in groups variable. 
  display_name     = each.value.display_name
  description      = each.value.description
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}
