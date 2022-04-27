# bastion 생성

resource "azurerm_public_ip" "bastion_public_ip" { # 퍼블릭 아이피 생성
  name                = var.bastion_public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = var.bastion_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.network.vnet_subnets[2] # subnet 지정 -- Bastion
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}