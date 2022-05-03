# # Bastion - 네트워크 보안그룹
resource "azurerm_network_security_group" "bastion-sg" {
  name                = "bastion-sg-name"
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name

  security_rule {
    name                       = "SSH" # 이름
    priority                   = 1001  # 규칙 우선순위
    direction                  = "Inbound"  # 트래픽의 방향
    access                     = "Allow"    # 허용 or 거부
    protocol                   = "Tcp"    # 프로토콜
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = ""  # Admin IP
    destination_address_prefix = "10.0.10.0/24" # Bastion Subnet
  }
}

# 네트워크 보안그룹 할당
resource "azurerm_network_interface_security_group_association" "bastion_connet_sg" {
  network_interface_id      = azurerm_network_interface.wp-bastion-network-interface.id
  network_security_group_id = azurerm_network_security_group.bastion-sg.id
}




# web_vmss - 네트워크 보안그룹
resource "azurerm_network_security_group" "webserver-sg" {
  name                = "webserver-sg-name"
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name

  security_rule {
    name                       = "SSH" # 이름
    priority                   = 1001  # 규칙 우선순위
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.10.0/24" # Bastion Subnet
    destination_address_prefix = "10.0.50.0/24" # VMSS Subnet
  }

  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "80"
    source_address_prefix      = "${azurerm_public_ip.wp-app-gateway-ip.ip_address}"
    destination_address_prefix = "10.0.50.0/24" # VMSS Subnet
  }


}
