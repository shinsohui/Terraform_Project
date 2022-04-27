# 네트워크 보안그룹
resource "azurerm_network_security_group" "webserver-sg" {
  name                = var.webserver-sg-name
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

  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# 네트워크 인터페이스
resource "azurerm_network_interface" "web_network_interface" {
  name                = "web_network_interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.test_public_ip.id # private test
  }
}

# 네트워크 보안그룹 할당
resource "azurerm_network_interface_security_group_association" "test_connet_sg" {
  network_interface_id      = azurerm_network_interface.web_network_interface.id
  network_security_group_id = azurerm_network_security_group.webserver-sg.id
}

# SSH key 생성                                                                                                                 
resource "tls_private_key" "wp_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



# 가상머신
resource "azurerm_linux_virtual_machine" "test-vm-webserver" {
  name                  = "test-vm-webserver"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.web_network_interface.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.linux_vm_image_publisher
    offer     = var.linux_vm_image_offer
    sku       = var.centos_7_sku
    version   = "latest"
  }

  computer_name                   = "wp"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.wp_ssh.public_key_openssh
  }
}

# cloud init
data "template_file" "linux-vm-cloud-init" {
  template = file("azure-user-data.sh")
}