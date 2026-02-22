variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}


variable "github_org" {
  description = "GitHub organization name for OIDC trust"
  type        = string
  default     = "*"
}

variable "github_repo" {
  description = "GitHub repository name for OIDC trust (format: org/repo or * for all repos)"
  type        = string
  default     = "*"
}

variable "grafana_account_id" {
  description = "AWS account ID that will assume the Grafana role"
  type        = string
  default     = "008923505280"
}

variable "grafana_external_id" {
  description = "External ID to require when Grafana assumes the role"
  type        = string
  default     = "1289231"
}
