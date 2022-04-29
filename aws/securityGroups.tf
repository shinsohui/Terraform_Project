# Security Group
## public Seucurity Group

# Basion host로 접속하기 위한 SSH 설정 
resource "aws_security_group" "bastionSG01" {
  name        = "bastion-SG"
  description = "Allow all SSH"
  vpc_id      = module.app_vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"] # 모든 ip 허용
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_security_group" "publicSG01" {
  name        = "public-SG-01"
  description = "Allow all HTTP"
  vpc_id      = module.app_vpc.vpc_id


  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

## from Bastion Host to private web server
resource "aws_security_group" "bastion-to-private" {
  name        = "bastion-to-private-sg"
  description = "Allow SSH from Bastion Host"
  vpc_id      = module.app_vpc.vpc_id


  ingress {
    # cidr_blocks = ["10.0.10.0/24"] # PublicSubnet1의 cidr_blocks
    cidr_blocks = ["${aws_instance.bastionhostEC201.private_ip}/32"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

## private Security Group
resource "aws_security_group" "privateEC2SG01" {
  name        = "private-ec2-sg-01"
  description = "Allow HTTP from ALB"
  vpc_id      = module.app_vpc.vpc_id

  ingress = [{
    cidr_blocks      = null
    description      = null
    from_port        = 80
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "tcp"
    security_groups  = [aws_security_group.publicSG01.id]
    self             = false
    to_port          = 80
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = null
    from_port        = 0
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "-1"
    security_groups  = null
    self             = false
    to_port          = 0
  }]


}

resource "aws_security_group" "privateRDSSG01" {
  name        = "private-rds-sg-01"
  description = "Allow acceess from private web instance"
  vpc_id      = module.app_vpc.vpc_id


  ingress = [{
    cidr_blocks      = null
    description      = null
    from_port        = 3306
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "tcp"
    security_groups  = [aws_security_group.privateEC2SG01.id]
    self             = false
    to_port          = 3306
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = null
    from_port        = 0
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "-1"
    security_groups  = null
    self             = false
    to_port          = 0
  }]
}

 