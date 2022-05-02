# 데이터베이스용 서브넷 지정
resource "aws_db_subnet_group" "testSubnetGroup" {
  name = "test"
  subnet_ids = [
    module.app_vpc.private_subnets[2],
    module.app_vpc.private_subnets[3]
  ]

  tags = {
    "Name" = "test-subnet-group"
  }
}

# RDS 인스턴스 리소스 생성하기
resource "aws_db_instance" "testDB" {
  allocated_storage     = 20
  max_allocated_storage = 50
  availability_zone     = "ap-northeast-2a"
  db_subnet_group_name  = aws_db_subnet_group.testSubnetGroup.name
  engine                = "mariadb"
  engine_version        = "10.5"
  instance_class        = "db.t3.small"
  skip_final_snapshot   = true
  identifier            = "project-db"
  name                  = "wordpress"     # DB name 
  username              = "admin"         # 사용자 이름 
  password              = var.db_password # 패스워드 (adminpass로)
  port                  = "3306"
  vpc_security_group_ids = [
    aws_security_group.privateRDSSG01.id
  ]
}

# default를 설정하지 않으면 apply 시에 직접 패스워드를 입력해야 한다.
variable "db_password" { 
  description = "RDS root user password"
  type        = string
  sensitive   = false
}
