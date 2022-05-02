# VMSS의 Subnet
resource "azurerm_subnet" "wp-web-subnet" {
  name                 = "wp-web-subnet"
  resource_group_name  = azurerm_resource_group.wp_rg.name
  virtual_network_name = azurerm_virtual_network.wp_network.name
  address_prefixes     = ["10.0.50.0/24"]
}

# 가상 머신 확장 집합 (Packer wordpress 이미지)
resource "azurerm_virtual_machine_scale_set" "vmss" {
  depends_on = [azurerm_public_ip.wp-app-gateway-ip, azurerm_application_gateway.wp-app-gateway]
  name                = "vmscaleset"
  location            = var.location
  resource_group_name = azurerm_resource_group.wp_rg.name
  upgrade_policy_mode = "Automatic" # VMSS의 가상머신에 대한 업그레이드 모드 지정

  zones = ["1", "2"]  # VMSS의 zone

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 16
  }

  # 리눅스 머신의 구성정보
  storage_profile_image_reference {
    id = data.azurerm_image.image.id
  }

  # 스토리지 프로필 OS 디스크 블록
  storage_profile_os_disk {
    name              = ""             # 이름을 유연하게 작성하지 않으면 여러 그룹이 생기면서 충돌할수있다.
    caching           = "ReadWrite"    # 캐싱 요구사항을 지정한다. (None, ReadOnly, ReadWrite)
    create_option     = "FromImage"    # 데이터 디스크를 생성하는 방법
    managed_disk_type = "Standard_LRS" # 생성할 관리 디스크의 유형 지정
  }

  # 스토리지 프로필 데이터 디스크 블록
  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  # OS에 대한 정보
  os_profile {
    computer_name_prefix = var.web_computer_name
    admin_username       = var.admin_user
    custom_data          = "${base64encode(
      <<-EOF
      #!/bin/bash
      sudo echo -e "\ndefine( 'WP_HOME', 'http://${azurerm_public_ip.wp-app-gateway-ip.ip_address}' );" >> /var/www/html/wordpress/wp-config.php
      sudo echo -e "\ndefine( 'WP_SITEURL', 'http://${azurerm_public_ip.wp-app-gateway-ip.ip_address}' );" >> /var/www/html/wordpress/wp-config.php
      sudo setenforce 0
      sudo systemctl restart httpd
      sudo systemctl restart mariadb
      EOF
    )}"
  }

  # OS가 리눅스 머신인 경우 설정
  os_profile_linux_config {
    disable_password_authentication = true # 패스워드 로그인 차단
    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  network_profile {
    name                      = "terraformnetworkprofile" # 네트워크 인터페이스 구성의 이름
    primary                   = true                      # 네트워크 인터페이스 구성에서 생성된 네트워크 인터페이스가 vm의 기본 NIC인지 여부
    network_security_group_id = azurerm_network_security_group.webserver-sg.id
    ip_configuration {
      name                                         = "IPConfiguration"               # ip 구성의 이름
      subnet_id                                    = azurerm_subnet.wp-web-subnet.id # 적용할 서브넷
      primary                                      = true                            # 이 ip config가 기본 구성인지?
      application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.wp-app-gateway.backend_address_pool[*].id}" # application gateway 백엔드 풀 연결
    }
  }
}
