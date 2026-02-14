variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "cors_origins" {
  description = "List of allowed CORS origins for API Gateway"
  type        = list(string)
}

variable "auth_integration_uri" {
  description = "Optional HTTP integration URI for /auth routes (e.g., http://host:port)."
  type        = string
  default     = null
}
