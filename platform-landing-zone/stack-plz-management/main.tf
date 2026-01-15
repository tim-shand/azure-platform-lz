# Management: Resource Group, Storage Account
# Contains the Storage Account for centralised log collection and Log Analytics Workspace. 
# resource "azurerm_resource_group" "plz_gov_rg" {
#   name     = "${local.prefix}-rg"
#   location = var.global.location
#   tags     = local.tags_merged
# }

# module "plz_gov_sa" {
#   source                   = "../../modules/gen-secure-storage-account"
#   storage_account_name     = "${local.prefix}-logs-sa"
#   resource_group_name      = azurerm_resource_group.plz_gov_rg.name
#   location                 = azurerm_resource_group.plz_gov_rg.location
#   tags                     = local.tags_merged
#   account_tier             = "Standard"
#   account_kind             = "StorageV2"
#   account_replication_type = "LRS"
# }
