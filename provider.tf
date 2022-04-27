terraform {
  required_version = ">= 0.14.9"

  required_providers {
    aws = "~> 3.0"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}
