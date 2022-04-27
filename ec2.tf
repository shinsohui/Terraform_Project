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


resource "aws_instance" "project-EC2-01" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.privateEC2SG01.id,
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
    aws_security_group.privateEC2SG01.id
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


