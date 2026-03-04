#====================================================================================#
# Connectivity: Hub VNet
# Description: 
# - Create VNet for centralized hub connecitivity.
# - Create subnets for firewall, bastion, gateway and management. 
#====================================================================================#

# VNet: Hub
resource "azurerm_virtual_network" "hub" {
  name                = "${module.naming_con.full_name}-vnet"
  resource_group_name = azurerm_resource_group.con.name
  location            = azurerm_resource_group.con.location
  tags                = local.tags_merged
  address_space       = var.vnet_hub_cidr
  dynamic "subnet" {
    for_each = local.hub_subnets_enabled
    content {
      name                            = lower("subnet-${subnet.key}")                # Use the object key as name. 
      address_prefixes                = subnet.value.address_prefixes                # List of addresses for subnet.
      default_outbound_access_enabled = subnet.value.default_outbound_access_enabled # Enable default outbound access to the internet for the subnet.
    }
  }
}
