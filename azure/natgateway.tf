resource "azurerm_public_ip" "wp-ng-ip" {
  name                = "nat-gateway-publicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "wp-ng" {
  name                    = "nat-Gateway"
  location                = var.location
  resource_group_name     = azurerm_resource_group.wp_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}


# 할당
resource "azurerm_nat_gateway_public_ip_association" "public-ip-ng-connect" {
  nat_gateway_id       = azurerm_nat_gateway.wp-ng.id
  public_ip_address_id = azurerm_public_ip.wp-ng-ip.id
}

resource "azurerm_subnet_nat_gateway_association" "wp-ng-connect" {
  subnet_id      = azurerm_subnet.wp-web-subnet.id
  nat_gateway_id = azurerm_nat_gateway.wp-ng.id
}