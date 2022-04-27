output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.test_public_ip
}

output "tls_private_key" {
  value     = tls_private_key.test_ssh.private_key_pem
  sensitive = true
}