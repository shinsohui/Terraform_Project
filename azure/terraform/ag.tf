# Application gateway의 퍼블릭 아이피
resource "azurerm_public_ip" "wp-app-gateway-ip" {
  name                = "wp-app-gateway-ip"
  resource_group_name = azurerm_resource_group.wp_rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application gateway Subnet
resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.wp_rg.name
  virtual_network_name = azurerm_virtual_network.wp_network.name # wp꺼
  address_prefixes     = ["10.0.70.0/24"]
}

resource "azurerm_application_gateway" "wp-app-gateway" {
  name                = "wp-app-gateway"
  resource_group_name = azurerm_resource_group.wp_rg.name
  location            = var.location


  # Application Gateway에서 사용할 SKU
  sku {
    name = "Standard_v2" # AZ 영역 확장 설정은 V2에서만 가능
    tier = "Standard_v2"
  }

# 상태체크 프로브
  probe {
    interval                                  = 30  # 다음 상태 프로브가 전송되기 전에 대시가는 시간(초)
    minimum_servers                           = 2   # 최소 서버 0 -> 2로 변경
    name                                      = local.backend_http_probe  # 프로브 이름
    path                                      = "/"   # 경로
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Http"  # 프로토콜
    timeout                                   = 30  # 타임아웃 시간
    unhealthy_threshold                       = 3   # 노드가 비정상으로 간주되기전에 시도해야하는 재시도 횟수 (비정상 임계값)
  }

  # 오토스케일링 설정
  autoscale_configuration {
    min_capacity = 4  # 최소 갯수
    max_capacity = 8  # 최대 갯수
  }

  # Application Gateway 설정
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id    # Application gateway의 서브넷
  }

  # 프론트엔드 포트
  frontend_port {
    name = local.frontend_port_name
    port = 80   # 80/tcp
  }

  # 프론트엔드 IP 설정
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name   # 프론트엔드 IP 구성의 이름
    public_ip_address_id = azurerm_public_ip.wp-app-gateway-ip.id # Application gateway에 사용할 공용 IP주소의 ID
  }


  # 백엔드 풀 지정 - 연결대상(vmss)
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  # 백엔드 http 설정
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled" # 쿠키 기반 선호도 활성화 여부
    # path                  = "/path1/"
    port            = 80     # 백엔드 HTTP 설정에서 사용하는 포트
    protocol        = "Http" # 프로토콜
    request_timeout = 120     # 요청 제한시간 (초)
    probe_name                          = local.backend_http_probe    # 상태체크 프로브 이름
    pick_host_name_from_backend_address = true
  }

  # http 리스너
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http" # 프로토콜
  }

  # 라우팅 규칙
  request_routing_rule {
    name                       = local.request_routing_rule_name # 요청 라우팅 규칙의 이름
    rule_type                  = "Basic"                         # 라우팅 유형
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
