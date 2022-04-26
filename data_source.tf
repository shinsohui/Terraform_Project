# 데이터 소스를 사용하는 파일
# 최신의 이미지를 사용하기 위해 filter를 이용한다.

data "aws_ami" "ubuntu_image" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}