# 테라폼 버전 1.1.9
# provider version 3.4.0

# 1. 리소스 그룹 생성
resource "azurerm_resource_group" "wp_rg" {
  name     = "WordpressResourcegroup"
  location = var.location
}

# 2. 네트워크 생성(vpc)
resource "azurerm_virtual_network" "wp_network" {
  name                = "Wordpress-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name
}

# 1. Bastion Instance의 서브넷
resource "azurerm_subnet" "wp-bastion-subnet" {
  name                 = "Bastion-subnet"
  resource_group_name  = azurerm_resource_group.wp_rg.name
  virtual_network_name = azurerm_virtual_network.wp_network.name
  address_prefixes     = ["10.0.10.0/24"]
}

# 1-1. Bastion public IP
resource "azurerm_public_ip" "wp-bastion-public-ip" {
  name                = "Bastion-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name
  allocation_method   = "Static"
}

# 1-2 Bastion 네트워크 인터페이스 생성
resource "azurerm_network_interface" "wp-bastion-network-interface" {
  name                = "Bastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name

  ip_configuration {
    name                          = "Bastion_IPConfiguration"
    subnet_id                     = azurerm_subnet.wp-bastion-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wp-bastion-public-ip.id
  }
}

# 1-3. Bastion VM 생성
resource "azurerm_virtual_machine" "wp-bastion-vm" {
  name                  = "Bastion-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.wp_rg.name
  network_interface_ids = [azurerm_network_interface.wp-bastion-network-interface.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = var.linux_vm_image_publisher
    offer     = var.linux_vm_image_offer
    sku       = var.centos_7_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "Bastion-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.bastion_computer_name
    admin_username = var.admin_user
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
}
