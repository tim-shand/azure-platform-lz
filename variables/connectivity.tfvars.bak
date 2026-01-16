# Connectivity: Network (Hub) -----------------#

hub_vnet_space = "10.250.0.0/16"
hub_subnets = {
  "AzureManagementSubnet" = {
    name                    = "mgt"
    address                 = ["10.250.0.0/24"]
    default_outbound_access = false
  }
  "AzureFirewallSubnet" = {
    name                    = "fwl"
    address                 = ["10.250.1.0/26"]
    default_outbound_access = true
  }
  "AzureGatewaySubnet" = {
    name                    = "gwy"
    address                 = ["10.250.2.0/24"]
    default_outbound_access = false
  }
  "AzureBastionSubnet" = {
    name                    = "bas"
    address                 = ["10.250.3.0/26"]
    default_outbound_access = false
  }
}
