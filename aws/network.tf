# VPC
resource "aws_vpc" "project-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "terraform-project-vpc"
  }
}

# VPC Endpoint
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = aws_vpc.project-vpc.id
#   service_name = "com.amazonaws.ap-northeast-1.s3"
# }

# Subnets
## public subnet
resource "aws_subnet" "publicSubnet1" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "project-public-subnet-01"
  }
}

resource "aws_subnet" "publicSubnet2" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    "Name" = "project-public-subnet-02"
  }
}

## private ec2 subnet
resource "aws_subnet" "privateEC2Subnet1" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.50.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "project-private-ec2-subnet-01"
  }
}

resource "aws_subnet" "privateEC2Subnet2" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.60.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    "Name" = "project-private-ec2-subnet-02"
  }
}

## private rds subnet
resource "aws_subnet" "privateRDSSubnet1" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "project-private-rds-subnet-01"
  }
}

resource "aws_subnet" "privateRDSSubnet2" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    "Name" = "project-private-rds-subnet-02"
  }
}

# IGW
resource "aws_internet_gateway" "project-vpc-IGW" {
  vpc_id = aws_vpc.project-vpc.id
  tags = {
    "Name" = "project-IGW"
  }
}

# NAT Gateway
# private subnet에서 외부 인터넷으로 요청을 내보낼 수 있도록 하는 NAT gateway
# NAT gateway에서 사용할 eip를 하나 만들고 NGW와 연결한 뒤 public subnet에 만든다.
# IGW 생성 후 구성하기 위해 명시적 의존성을 지정했다.
resource "aws_eip" "project-vpc-NAT-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.project-vpc-IGW]
}

resource "aws_nat_gateway" "project-vpc-NAT" {
  allocation_id = aws_eip.project-vpc-NAT-eip.id
  subnet_id     = aws_subnet.publicSubnet1.id
  depends_on    = [aws_internet_gateway.project-vpc-IGW]
}

# Route Table
# PublicRTb
resource "aws_route_table" "project-vpc-PublicRTb" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-vpc-IGW.id
  }

  tags = {
    "Name" = "project-public-rtb"
  }
}

# private subnet에서 사용할 route table을 생성하고 
# 여기서 0.0.0.0/0으로 나가는 요청이 모두 NGW로 가도록 설정한다.
resource "aws_route_table" "project-vpc-PrivateRTb" {
  vpc_id = aws_vpc.project-vpc.id
  tags = {
    "Name" = "project-private-rtb"
  }
}

resource "aws_route" "project-vpc-PrivateRT" {
  route_table_id         = aws_route_table.project-vpc-PrivateRTb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.project-vpc-NAT.id
}

## route
# ### vpc endpoint associate
# resource "aws_vpc_endpoint_route_table_association" "publicRTbEndpoint" {
#   route_table_id  = aws_route_table.testPublicRTb.id
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }

# resource "aws_vpc_endpoint_route_table_association" "privateRTbEndpoint" {
#   route_table_id  = aws_route_table.testPrivateRTb.id
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }

### subnet associate
### publicSubnet1 과 PublicRTb 연결
resource "aws_route_table_association" "publicRTbAssociation01" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.project-vpc-PublicRTb.id
}

### publicSubnet2 와 PublicRTb 연결
resource "aws_route_table_association" "publicRTbAssociation02" {
  subnet_id      = aws_subnet.publicSubnet2.id
  route_table_id = aws_route_table.project-vpc-PublicRTb.id
}

### publicEC2Subnet1 과 PrivateRTb 연결
resource "aws_route_table_association" "privateRTbAssociation01" {
  subnet_id      = aws_subnet.privateEC2Subnet1.id
  route_table_id = aws_route_table.project-vpc-PrivateRTb.id
}

### publicEC2Subnet2 와 PrivateRTb 연결
resource "aws_route_table_association" "privateRTbAssociation02" {
  subnet_id      = aws_subnet.privateEC2Subnet2.id
  route_table_id = aws_route_table.project-vpc-PrivateRTb.id
}

### publicRDSSubnet1 과 PrivateRTb 연결
resource "aws_route_table_association" "privateRTbAssociation03" {
  subnet_id      = aws_subnet.privateRDSSubnet1.id
  route_table_id = aws_route_table.project-vpc-PrivateRTb.id
}

### publicRDSSubnet2 와 PrivateRTb 연결
resource "aws_route_table_association" "privateRTbAssociation04" {
  subnet_id      = aws_subnet.privateRDSSubnet2.id
  route_table_id = aws_route_table.project-vpc-PrivateRTb.id
}