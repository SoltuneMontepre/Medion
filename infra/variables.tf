variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "medion"
}

variable "organization" {
  description = "The organization name for Terraform Cloud"
  type        = string
  default     = "medion"
}