locals {
  backend_address_pool_name      = "${azurerm_virtual_network.wp_network.name}-beap"        # 백엔드 풀 주소 이름
  frontend_port_name             = "${azurerm_virtual_network.wp_network.name}-feport"      # 프론트엔드 포트 이름
  frontend_ip_configuration_name = "${azurerm_virtual_network.wp_network.name}-feip"        # 프론트엔드 ip_config 이름
  http_setting_name              = "${azurerm_virtual_network.wp_network.name}-be-htst"     # http 세팅 이름
  listener_name                  = "${azurerm_virtual_network.wp_network.name}-httplstn"    # http 리스너 이름
  request_routing_rule_name      = "${azurerm_virtual_network.wp_network.name}-rqrt"        # 요청 라우팅 규칙의 이름
  redirect_configuration_name    = "${azurerm_virtual_network.wp_network.name}-rdrcfg"      # redirect_configuration_name
  backend_http_probe             = "${azurerm_virtual_network.wp_network.name}-httpprobe"   # 백엔드 상태프로브 이름
}