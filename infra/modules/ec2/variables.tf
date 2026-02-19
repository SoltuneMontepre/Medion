variable "name_prefix" {
  description = "Name prefix for EC2 resources."
  type        = string
  default     = "medion"
}

variable "instance_type" {
  description = "EC2 instance type. Use a free-tier type when available."
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "http_allowed_cidr" {
  description = "CIDR block allowed to reach HTTP on the instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "https_allowed_cidr" {
  description = "CIDR block allowed to reach HTTPS on the instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "subnet_id" {
  description = "Optional subnet ID override."
  type        = string
  default     = null
}
