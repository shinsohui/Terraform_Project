# 애플리케이션 게이트웨이 아이피
output "app_ip" {
  value = azurerm_public_ip.wp-app-gateway-ip
}

# Bastion 아이피
output "Bastion_ip_address" {
  value = azurerm_public_ip.wp-bastion-public-ip
}