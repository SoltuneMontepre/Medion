# =============================================================================
# Outputs - Main Infrastructure Values
# =============================================================================

output "cors_origins" {
  description = "CORS allowed origins for API Gateway"
  value       = var.cors_origins
}

# =============================================================================
# ECR
# =============================================================================

output "ecr_repositories" {
  description = "ECR repository URLs for Docker images"
  value       = module.ecr.repository_urls
}

output "ecr_registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = module.ecr.registry_id
}

# =============================================================================
# IAM - GitHub Actions
# =============================================================================

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions role for ECR access (add this to GitHub secrets)"
  value       = module.iam.github_actions_ecr_role_arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider"
  value       = module.iam.github_oidc_provider_arn
}

# =============================================================================
# API Gateway
# =============================================================================
output "api_gateway_domain" {
  description = "Domain name of the API Gateway"
  value       = module.api_gateway.api_gateway_domain
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_gateway_id
}
