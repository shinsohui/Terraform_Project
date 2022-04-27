locals {
  common_tags = {
    Name         = "Terraform Project"
    project_name = var.project_name
    project_env  = var.project_environment
  }
}