# Packer로 만든 이미지의 id 출력
output "pakcer-image" {
  value = data.aws_ami.wordpressLinux.id
}

# db 엔드포인트 출력
output "wordpress_db_endpoint" {
  value = aws_db_instance.testDB.endpoint
}

# Bastion Host 프라이빗 ip 출력
output "bastion-instance-private" {
  value = aws_instance.bastionhostEC201.private_ip
}

# Bastion Host 퍼블릭 ip 출력
output "bastion-instance-public" {
  value = aws_instance.bastionhostEC201.public_ip
}

# 로드밸런서 도메인 출력
output "alb_domain" {
  value = aws_alb.project-elb.dns_name
} 

