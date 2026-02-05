variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "cors_origins" {
  description = "List of allowed CORS origins for API Gateway"
  type        = list(string)
}
