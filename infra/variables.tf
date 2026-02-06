variable "cors_origins" {
  description = "List of allowed CORS origins for API Gateway"
  type        = list(string)
  default     = ["http://localhost:4200", "http://localhost:4201"]
}

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "ap-southeast-1"
}

variable "doppler_project" {
  description = "doppler project name"
  type        = string
  default     = "medion"
}

variable "doppler_config" {
  type        = string
  description = "doppler config"
  default     = "dev"
}
