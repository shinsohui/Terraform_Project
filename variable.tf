# 변수를 모아놓은 파일
# 자주 변경되는 변수들은 terraform.tfvars에 빼놓으면 편리하다.

variable "instance_name" {
  type        = string
  description = "Instance Name"
  default     = "App Instance"
}

variable "instance_count" {
 description = "Instance Count"
 type = number
 default = 2 
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_availability_zone" {
  description = "AWS AZs"
  type        = map(string)
  default = {
    ap-northeast-1 = "ap-northeast-1c"
    ap-northeast-2 = "ap-northeast-2c"
    ap-northeast-3 = "ap-northeast-3c"
  }
}

variable "aws_amazon_linux_ami" {
  description = "Amazon Linux 5.10 AMI Image"
  type        = map(string)
  default = {
    ap-northeast-1 = "ami-0bcc04d20228d0cf6"
    ap-northeast-2 = "ami-02e05347a68e9c76f"
    ap-northeast-3 = "ami-0fe7b77eb0549da6c"
  }

}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "My_First_Project"
}

variable "project_environment" {
  description = "Project Environment"
  type        = string
  default     = "Local Development"
}
