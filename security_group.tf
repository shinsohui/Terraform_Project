# 보안 그룹 설정 파일 
# 인바운드, 아웃바운드 설정 및 vpc_id 지정 필수

resource "aws_security_group" "app_server_sg" {
  name   = "Allow SSH & HTTP"
  vpc_id = module.app_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["211.216.24.136/32"] # 내 ip에서만 접속되도록
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags

}