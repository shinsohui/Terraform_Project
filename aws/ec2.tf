# SSH 접속을 위한 공개키 설정
resource "aws_key_pair" "app_server_key" {
  key_name   = "app_server_key"
  public_key = file("~/.ssh/app_server_key.pub")
}

# Bastion Host 인스턴스 생성
resource "aws_instance" "bastionhostEC201" {
  ami                    = data.aws_ami.amazonLinux.id
  availability_zone      = aws_subnet.publicSubnet1.availability_zone
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastionSG01.id]
  subnet_id              = aws_subnet.publicSubnet1.id
  key_name               = aws_key_pair.app_server_key.key_name

  tags = local.common_tags
}

# 사용자 데이터를 이용해 AMI 이미지를 만든다.



# web server가 구동될 EC2 instance는 Auto Scaling을 통해 생성할 것이고, 
# 생성할 때 각 Instance에 적용할 Launch Template을 생성한다.
resource "aws_launch_template" "project-launch-template" {
  # 명시적 의존성
  depends_on = [
    aws_subnet.privateEC2Subnet1,
    aws_subnet.privateEC2Subnet2,
    aws_db_subnet_group.testSubnetGroup
  ]

  name                                 = "project-launch-template"
  description                          = "for Auto Scaling"
  instance_type                        = "t2.micro"
  image_id                             = data.aws_ami.amazonLinux.id
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.app_server_key.key_name
  vpc_security_group_ids               = [aws_security_group.privateEC2SG01.id]

  monitoring {
    enabled = true # 모니터링 활성화 
  }

  # network_interfaces {
  #   associate_public_ip_address = true
  #   subnet_id = aws_subnet.privateRDSSubnet1.id 
  #   # 이렇게하면 string 오류는 나지 않는다.              
  # }

  placement {
    availability_zone = "ap-northeast-2"
  }

  tags = {
    "Name" = "project-web-ec2"
  }
}

# web server가 구동될 EC2들을 Auto Scaling하기 위한 Auto Scaling Group 생성
resource "aws_autoscaling_group" "project-ASG" {
  launch_template {
    id = aws_launch_template.project-launch-template.id
  }

  desired_capacity = 2 # 원하는 인스턴스의 개수 2개
  min_size         = 2 # 최소 인스턴스 개수 2개
  max_size         = 4 # 최대 인스턴스 개수 4개

  health_check_type         = "ELB"
  health_check_grace_period = 180 # 3분
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.privateEC2Subnet1.id, aws_subnet.privateEC2Subnet2.id]
  # availability_zones        = ["ap-northeast-2a", "ap-northeast-2c"]
}

resource "aws_instance" "project-EC2-01" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.privateEC2SG01.id,
  aws_security_group.bastion-to-private.id]

  subnet_id = aws_subnet.privateEC2Subnet1.id
  key_name  = aws_key_pair.app_server_key.key_name

  # root_block_device {
  #   volume_size = 50
  #   volume_type = "gp3"
  #   tags = {
  #     "Name" = "test-private-ec2-01-vloume-1"
  #   }
  # }

  tags = {
    "Name" = "test-private-ec2-01"
  }
}

resource "aws_instance" "project-EC2-02" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.privateEC2SG01.id,
    aws_security_group.bastion-to-private.id
  ]
  subnet_id = aws_subnet.privateEC2Subnet2.id
  key_name  = aws_key_pair.app_server_key.key_name

  # root_block_device {
  #   volume_size = 50
  #   volume_type = "gp3"
  #   tags = {
  #     "Name" = "test-private-ec2-02-vloume-1"
  #   }
  # }

  tags = {
    "Name" = "test-private-ec2-02"
  }
}

resource "aws_eip" "project-bastion-eip" {
  instance = aws_instance.bastionhostEC201.id
  vpc      = true
  tags     = local.common_tags
}


