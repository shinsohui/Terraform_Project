output "tls_private_key" {
  value     = tls_private_key.wp_ssh.private_key_pem
  sensitive = true
}