resource "aws_lambda_function" "this" {
  function_name = "${var.project_name}-${var.service_name}"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository}:latest"

  memory_size   = 1024
  timeout       = 60
  architectures = ["x86_64"]

  environment {
    variables = merge(var.environment_variables, {
      # AWS Lambda Web Adapter configuration (binary is COPY'd into Docker image)
      PORT                         = "8080"
      AWS_LWA_READINESS_CHECK_PORT = "8080"
      AWS_LWA_READINESS_CHECK_PATH = "/health"
      AWS_LWA_ASYNC_INIT           = "true"
      # Strip the /api/{service} prefix so the app receives clean paths
      AWS_LWA_REMOVE_BASE_PATH = "/api/${var.service_name}"
    })
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

