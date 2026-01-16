# DEV / TEST

module "naming" {
  source      = "../../modules/global-resource-naming"
  org_prefix  = "tjs"
  project     = "bootstrap"
  category1   = "iac"
  category2   = ""
  environment = "plz"
}

resource "azurerm_resource_group" "dev_rg" {
  name     = "${module.naming.full}-rg"
  location = "newzealandnorth"
}

module "dev_sa" {
  source               = "../../modules/storage-account-secure"
  storage_account_name = "${module.naming.short}sa"
  resource_group_name  = azurerm_resource_group.dev_rg.name
  location             = azurerm_resource_group.dev_rg.location
  tags = {
    Owner = "TEST"
  }
}
