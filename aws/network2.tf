module "app_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app_vpc"

  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]
  private_subnets = ["10.0.50.0/24", "10.0.60.0/24", "10.0.100.0/24", "10.0.200.0/24"]

  create_database_subnet_group = true

  create_igw = true

  enable_nat_gateway = true
  single_nat_gateway = true

}
