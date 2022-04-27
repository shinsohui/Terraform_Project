variable "bastion_public_ip_name" {
  description = "Bastion의 Public IP 이름"
  type        = string
  default     = "bastion_public_ip"
}

variable "bastion_name" {
  description = "Bastion의 이름"
  type        = string
  default     = "WP_bastion_host"
}

