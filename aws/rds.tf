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

# ## private rds subnet
# resource "aws_subnet" "privateRDSSubnet1" {
#   vpc_id            = aws_vpc.project-vpc.id
#   cidr_block        = "10.0.100.0/24"
#   availability_zone = "ap-northeast-2a"
#   tags = {
#     "Name" = "project-private-rds-subnet-01"
#   }
# }

# resource "aws_subnet" "privateRDSSubnet2" {
#   vpc_id            = aws_vpc.project-vpc.id
#   cidr_block        = "10.0.200.0/24"
#   availability_zone = "ap-northeast-2c"
#   tags = {
#     "Name" = "project-private-rds-subnet-02"
#   }
# }

resource "aws_db_instance" "testDB" {
  allocated_storage     = 20
  max_allocated_storage = 50
  availability_zone     = "ap-northeast-2a"
  db_subnet_group_name  = aws_db_subnet_group.testSubnetGroup.name
  engine                = "mariadb"
  engine_version        = "10.5"
  instance_class        = "db.t3.small"
  skip_final_snapshot   = true
  identifier            = "test-maridb"
  username              = "root"
  password              = var.db_password
  name                  = "testDB"
  port                  = "3306"
  vpc_security_group_ids = [
    aws_security_group.privateRDSSG01.id
  ]
}

