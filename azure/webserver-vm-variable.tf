variable "webserver-sg-name" {
  description = ""
  type        = string
  default     = "Webserver-sg"
}

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