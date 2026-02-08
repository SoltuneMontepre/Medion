### Microservice Metadata

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "service_name" {
  description = "Name of the microservice, used for resource naming"
  type        = string
}

### Permission Variabless

variable "lambda_role_arn" {
  description = "ARN of the IAM role to be assumed by the Lambda function"
  type        = string
}

### ECR Repository

variable "ecr_repository" {
  description = "ECR repository URL for the microservice Docker image"
  type        = string
}

### API Gateway Integration

variable "api_gateway_id" {
  description = "ID of the API Gateway to integrate with"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

### Lambda Configuration
variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Amount of memory in MB for Lambda function (128-10240). More memory = more CPU = faster cold starts"
  type        = number
  default     = 3008 # ~2 vCPUs for better initialization performance
}

variable "timeout" {
  description = "Lambda function timeout in seconds (1-900)"
  type        = number
  default     = 120
}

variable "ephemeral_storage_size" {
  description = "Ephemeral storage size in MB for /tmp directory (512-10240)"
  type        = number
  default     = 1024 # Increased from default 512 MB for data protection keys
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions to keep instances warm. -1 = unreserved, 0 = disabled, >0 = reserved count"
  type        = number
  default     = -1 # Unreserved by default
}

