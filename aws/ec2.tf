# SSH 접속을 위한 공개키 설정
resource "aws_key_pair" "app_server_key" {
  key_name   = "app_server_key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}

# Bastion Host 인스턴스 생성
resource "aws_instance" "bastionhostEC201" {
  ami                    = data.aws_ami.amazonLinux.id
  availability_zone      = module.app_vpc.azs[0] # 2a
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastionSG01.id]
  subnet_id              = module.app_vpc.public_subnets[0]
  key_name               = aws_key_pair.app_server_key.key_name # vagrant의 공개키를 등록함
 
  # vagrant의 개인키를 이용해 서버에 접속하는 코드
  connection {
    user        = "ec2-user" # host = aws_instance.app_server 가능
    host        = self.public_ip
    private_key = file("/home/vagrant/.ssh/id_rsa") # vagrant private key로 접속
  }

  provisioner "file" {
    source      = "/home/vagrant/.ssh/id_rsa" # 현재 디렉토리에 있는 app_server_key
    destination = "/tmp/id_rsa"               # 임시 디렉토리로 이동
  }

  # provisioner를 사용하여 ssh 키페어 생성 명령을 실행한다.
  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/id_rsa /home/ec2-user/.ssh/id_rsa",
      "sudo chmod 400 /home/ec2-user/.ssh/id_rsa"
    ]
  }
}

# 이미지용 instance 생성하기 
# resource "aws_instance" "instance-for-ami" {
#   ami                    = data.aws_ami.amazonLinux.id
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.bastion-to-private.id]

#   subnet_id = module.app_vpc.private_subnets[0]
#   key_name  = aws_key_pair.app_server_key.key_name

#   tags = {
#     "Name" = "instance-for-ami"
#   }
# }

# 인스턴스로부터 이미지 만들기
# resource "aws_ami_from_instance" "project-ami" {
#   name               = "project-ami"
#   source_instance_id = aws_instance.instance-for-ami.id
#   #인스턴스 생성 후에 ami 생성
#   depends_on = [
#     aws_instance.instance-for-ami
#   ]
# }

# web server가 구동될 EC2 instance는 Auto Scaling을 통해 생성할 것이고, 
# 생성할 때 각 Instance에 적용할 Launch Template을 생성한다.
resource "aws_launch_template" "project-launch-template" {
  # 명시적 의존성
  depends_on = [
    module.app_vpc.public_subnets,
    aws_db_subnet_group.testSubnetGroup,
    aws_db_instance.testDB # DB를 생성한 후 엔드포인트를 가져와야 함
  ]

  name                                 = "project-launch-template"
  description                          = "for Auto Scaling"
  instance_type                        = "t2.micro"
  image_id                             = data.aws_ami.wordpressLinux.id
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.app_server_key.key_name
  vpc_security_group_ids               = [aws_security_group.privateEC2SG01.id, aws_security_group.bastion-to-private.id]

  # DB 엔드포인트 변경을 위한 사용자 데이터 작성 라인
  # sed -i "s/[찾는문자열]/[수정문자열]" 파일명
  # wp-config.php 에서 내용 수정하기
  user_data = "${base64encode(
    <<-EOF
    #!/bin/bash
    sed -i 's/tmp_endpoint/${aws_db_instance.testDB.endpoint}/g' /var/www/html/wordpress/wp-config.php
    systemctl restart httpd
    systemctl restart mariadb
    EOF
    )}"

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
    "Name" = "project-ec2-template"
  }
}

