#====================================================================================#
# Connectivity: Azure Bastion Host
# Description: 
# - Create public IP for Bastion host.
# - Create Azure Bastion in dedicated subnet from hub VNet.
#====================================================================================#

# Bastion: Public IP
resource "azurerm_public_ip" "bastion" {
  count               = var.hub_services.bastion.enabled ? 1 : 0 # If Bastion enabled, create, else do not.
  name                = "${module.naming_con.full_name}-bas-pip"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion: Bastion Host
resource "azurerm_bastion_host" "bastion" {
  count               = var.hub_services.bastion.enabled ? 1 : 0 # If Bastion enabled, create, else do not.
  name                = "${module.naming_con.full_name}-bas"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  sku                 = var.hub_services.bastion.sku # Standard required for 'Native client support'. 
  ip_configuration {
    name                 = "ip-config-bas"
    subnet_id            = azurerm_subnet.hub["bastion"].id #var.hub_services.bastion.subnet
    public_ip_address_id = azurerm_public_ip.bastion[0].ip_address
  }
  copy_paste_enabled     = var.hub_services.bastion.copy_paste_enabled                                                       # Basic, Standard
  file_copy_enabled      = var.hub_services.bastion.sku == "Basic" ? false : var.hub_services.bastion.file_copy_enabled      # REQUIRES: Standard
  tunneling_enabled      = var.hub_services.bastion.sku == "Basic" ? false : var.hub_services.bastion.tunneling_enabled      # REQUIRES: Standard
  shareable_link_enabled = var.hub_services.bastion.sku == "Basic" ? false : var.hub_services.bastion.shareable_link_enabled # REQUIRES: Standard
  kerberos_enabled       = var.hub_services.bastion.sku == "Basic" ? false : var.hub_services.bastion.kerberos_enabled       # REQUIRES: Standard
  ip_connect_enabled     = var.hub_services.bastion.sku == "Basic" ? false : var.hub_services.bastion.ip_connect_enabled     # REQUIRES: Standard
}
