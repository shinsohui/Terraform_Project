module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = "test"
  address_spaces      = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/26"]
  subnet_names        = ["webserver", "dbserver", "AzureBastionSubnet"]
  # Bation Host를 만들기 위해서는 서브넷 이름이 AzureBastionSubnet이고 prifix /26 이상이 있어야함
  #   subnet_service_endpoints = {
  #     "subnet1" : ["Microsoft.Sql"], 
  #     "subnet2" : ["Microsoft.Sql"],
  #     "subnet3" : ["Microsoft.Sql"]
  #   }

  depends_on = [azurerm_resource_group.rg]
}