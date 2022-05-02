# 태그를 한번에 관리
# 사용하지 않았음
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
