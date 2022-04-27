/*module "app_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c", "ap-northeast-2d"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

}

resource "aws_key_pair" "app_server_key" {
  key_name   = "app_server_key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}
*/

resource "aws_instance" "app_server" {

  count = var.instance_count

  # ami           = var.aws_amazon_linux_ami[var.aws_region]
  ami = data.aws_ami.ubuntu_image.image_id # data source를 
  instance_type = "t3.small"
  # availability_zone      = var.aws_availability_zone[var.aws_region]
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[0]


  # 사용자 데이터 작성  
  # user_data = <<-EOF
  #   #!/bin/sh
  #   yum -y install httpd
  #   systemctl enable --now httpd
  #   echo "hello world" > /var/www/html/index.htm
  #   EOF
  # user_data = file("userdata.sh")

  # vagrant의 개인키를 이용해 ec2 서버에 접속하는 코드
  # connection {
  #   user        = "ec2-user" # host = aws_instance.app_server 가능
  #   host        = self.public_ip
  #   private_key = file("/home/vagrant/.ssh/id_rsa")
  #   timeout     = "1m"
  # }

  # file 프로바이저를 사용해 ec2의 index.html을 변경하기
  # provisioner "file" {
  #   source      = "index.html"
  #   destination = "/tmp/index.html"
  # }


  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum install -y httpd",
  #     "sudo systemctl enable --now httpd",
  #     "sudo cp /tmp/index.html /var/www/html/index.html"
  #   ]
  # }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} ansible_user=ec2-user > inven.ini"

  # }

  # provisioner "local-exec" {
  #   command = "ansible-playbook -i inven.ini web_install.yaml -b"
  # }

  tags = local.common_tags

  depends_on = [
    aws_s3_bucket.app_bucket
  ]
  # 명시적 의존성
  # 명시적 의존성을 이용해 s3 버킷을 먼저 생성하기 
}

# 2번째 인스턴스 count 변수를 사용하여 여러개 만들 수 있으므로 
# 해당 코드는 비효율적인 코드이다. (물론 같은 조건으로 만들 것이 아니라면 해당 코드는 비효율적이지 않다.)

# resource "aws_instance" "app_server2" {
#   ami           = var.aws_amazon_linux_ami[var.aws_region]
#   instance_type = "t3.small"
#   # availability_zone      = var.aws_availability_zone[var.aws_region]
#   vpc_security_group_ids = [aws_security_group.app_server_sg.id]
#   key_name               = aws_key_pair.app_server_key.key_name
#   subnet_id              = module.app_vpc.public_subnets[1]

#   tags = local.common_tags
# }

# eip 리소스 생성
# Elastic IP Resource
resource "aws_eip" "app_server_eip" {

  count = var.instance_count

  instance = aws_instance.app_server[count.index].id
  vpc      = true
  tags     = local.common_tags
}
# 암시적 의존성
# 암시적으로 public ip 생성 후 eip를 연결하도록 되어 있음 

# S3 Bucket
# resource "aws_s3_bucket" "app_bucket" {
#   bucket = "ssh-20220422"
#   tags   = local.common_tags

# }

