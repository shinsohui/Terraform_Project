# 출력 변수를 다루는 파일
# public ip, eip 생성 후 각 ip를 편리하게 출력하기 위해 사용한다.

output "app_server_elastic_ip" {
  value = aws_eip.app_server_eip.*.public_ip
}

output "app_server_public_ip" {
  value = aws_instance.app_server.*.public_ip
}
