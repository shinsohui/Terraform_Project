# 구독 / 리소스 그룹 이름 / 영역 / tags
resource "azurerm_resource_group" "rg" {
  name     = "testResourceGroup"
  location = var.resource_group_location
  tags = {
    name = "wp" # 예시
  }
}

# <기본사항> 프로젝트 정보 :구독 / 리소스 그룹  /// 인스턴스 정보 : 이름 / 지역
# <IP주소>  ipv4 주소 공간 / 서브넷 이름
# <보안> BastionHost (yes or no) / 방화벽 (yes or no)
# tags

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


# bastion 생성

resource "azurerm_public_ip" "test_public_ip" { # 퍼블릭 아이피 생성
  name                = "test_public_ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "test_bastion_host" {
  name                = "test_bastion_host"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.network.vnet_subnets[2] # subnet 지정 -- Bastion
    public_ip_address_id = azurerm_public_ip.test_public_ip.id
  }
}


# 네트워크 보안그룹 만들기
resource "azurerm_network_security_group" "test_sg" {
  name                = "test_sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH" # 이름
    priority                   = 1001  # 규칙 우선순위
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# # 네트워크 인터페이스 생성

resource "azurerm_network_interface" "test_network_interface" {
  name                = "test_network_interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.test_public_ip.id # private test
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "test_connet_sg" {
  network_interface_id      = azurerm_network_interface.test_network_interface.id
  network_security_group_id = azurerm_network_security_group.test_sg.id
}

# SSH key 생성
resource "tls_private_key" "test_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# vm 생성

resource "azurerm_linux_virtual_machine" "test-vm-webserver" {
  name                  = "test-vm-webserver"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.test_network_interface.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.test_ssh.public_key_openssh
  }
}

# # 네트워크 인터페이스 생성

resource "azurerm_network_interface" "test_network_interface2" {
  name                = "test_network_interface2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration2"
    subnet_id                     = module.network.vnet_subnets[1]
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.test_public_ip.id # private test
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "test_connet_sg2" {
  network_interface_id      = azurerm_network_interface.test_network_interface2.id
  network_security_group_id = azurerm_network_security_group.test_sg.id
}



# vm 생성

resource "azurerm_linux_virtual_machine" "test-vm-webserver2" {
  name                  = "test-vm-dbserver"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.test_network_interface2.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk2"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.test_ssh.public_key_openssh
  }
}