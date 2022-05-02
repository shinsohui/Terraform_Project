terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  # # terraform cloud를 사용하기 위한 코드
  # required_version = ">= 0.14.9"
  # cloud {
  #   organization = "shinsohui"

  #   workspaces {
  #     name = "terraform_test"
  #   }
  # }
}

provider "aws" {
  region = "ap-northeast-2"
}
