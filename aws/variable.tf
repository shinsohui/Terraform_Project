variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = false
}

# 태그 한번에 관리
variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "Terraform_project"
}

variable "project_environment" {
  description = "Project Environment"
  type        = string
  default     = "Local Development"
}