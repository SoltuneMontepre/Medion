resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${var.project_name}-api"
  description   = "API Gateway for ${var.project_name} project"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = var.cors_origins
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    allow_headers     = ["Authorization", "Content-Type", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    allow_credentials = true
    max_age           = 3600
  }

  disable_execute_api_endpoint = false
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "auth_http" {
  count = var.auth_integration_uri != null ? 1 : 0

  api_id                 = aws_apigatewayv2_api.api_gateway.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.auth_integration_uri
  payload_format_version = "1.0"
  connection_type        = "INTERNET"
}

resource "aws_apigatewayv2_route" "auth" {
  count = var.auth_integration_uri != null ? 1 : 0

  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /api/auth"
  target    = "integrations/${aws_apigatewayv2_integration.auth_http[0].id}"
}

resource "aws_apigatewayv2_route" "auth_proxy" {
  count = var.auth_integration_uri != null ? 1 : 0

  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /api/auth/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.auth_http[0].id}"
}
