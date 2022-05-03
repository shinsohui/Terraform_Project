variable "location" {
  type        = string
  description = "리소스 영역"
  default     = "koreacentral"
}


# -------- VM 이미지 정보 ----------

variable "linux_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "OpenLogic"
}

variable "linux_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "CentOS"
}

variable "centos_7_sku" {
  type        = string
  description = "SKU for latest CentOS 8 "
  default     = "7_9"
}

# -------- 계정정보 ----------

variable "bastion_computer_name" {
  type    = string
  default = "wp-bastion"
}

variable "admin_user" {
  type    = string
  default = "azureuser"
}

variable "web_computer_name" {
  type    = string
  default = "wp-web"
}

variable "subscription_id" {
  description = "Enter subscription_id"
  type        = string
  default = ""
}


variable "client_id" {
  description = "Enter client_id"
  type        = string
  default = ""
}


variable "client_secret" {
  description = "Enter client_secret"
  type        = string
  default = ""
}

variable "tenant_id" {
  description = "Enter tenant_id"
  type        = string
  default = ""
}


# -------- Application Gatway ----------


variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}


# -------- DB ----------

variable "mariadb-admin-login" {
  type        = string
  description = "Login to authenticate to mariadb Server"
  default     = ""
}
variable "mariadb-admin-password" {
  type        = string
  description = "Password to authenticate to mariadb Server"
  default     = ""
}
variable "mariadb-version" {
  type        = string
  description = "mariadb Server version to deploy"
  default     = "10.2"
}
variable "mariadb-sku-name" {
  type        = string
  description = "mariadb SKU Name"
  default     = "B_Gen5_1"
}
variable "mariadb-storage" {
  type        = string
  description = "mariadb Storage in MB"
  default     = "5120"
}


# -------- 이미지 사용시 ----------

variable "packer_resource_group_name" {
  description = "Name of the resource group in which the Packer image will be created"
  default     = "my-image"
}

variable "packer_image_name" {
  description = "Name of the Packer image"
  default     = "wordpress"
}