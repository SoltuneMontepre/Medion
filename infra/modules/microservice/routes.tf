resource "aws_apigatewayv2_route" "default_route" {
  api_id             = var.api_gateway_id
  route_key          = "ANY /api/${var.service_name}/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.default_integration.id}"
  authorization_type = "NONE"
}
