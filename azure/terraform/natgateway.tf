resource "azurerm_public_ip" "wp-ng-ip" {
  name                = "nat-gateway-publicIP"
  location            = var.location    # 영역 
  resource_group_name = azurerm_resource_group.wp_rg.name   # 리소스 그룹 이름
  allocation_method   = "Static"    # IP 할당 방식
  sku                 = "Standard"
  zones               = ["1"]   # IP 주소의 zone
}

resource "azurerm_nat_gateway" "wp-ng" {
  name                    = "nat-Gateway"
  location                = var.location    # 영역
  resource_group_name     = azurerm_resource_group.wp_rg.name # 리소스 그룹 이름
  sku_name                = "Standard"    # sku 이름
  idle_timeout_in_minutes = 10    # TCP 연결에 대한 유효시간 초과 지정(분)
  zones                   = ["1"] # NAT gateway zone
}


# 할당
resource "azurerm_nat_gateway_public_ip_association" "public-ip-ng-connect" {
  nat_gateway_id       = azurerm_nat_gateway.wp-ng.id     # NAT gateway의 이름
  public_ip_address_id = azurerm_public_ip.wp-ng-ip.id    # NAT gateway의 아이피
}

resource "azurerm_subnet_nat_gateway_association" "wp-ng-connect" {
  subnet_id      = azurerm_subnet.wp-web-subnet.id    # 할당할 서브넷
  nat_gateway_id = azurerm_nat_gateway.wp-ng.id   # NAT gateway의 이름
}