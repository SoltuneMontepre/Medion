resource "aws_lambda_function" "this" {
  function_name = "${var.project_name}-${var.service_name}"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository}:latest"

  # Increased memory for better cold start performance
  # More memory = more CPU = faster initialization
  memory_size   = var.memory_size
  timeout       = var.timeout
  architectures = ["x86_64"]

  # Increase ephemeral storage for data protection keys and temp files
  ephemeral_storage {
    size = var.ephemeral_storage_size # MB
  }

  # Reserved concurrent executions to keep instances warm
  # Set to -1 for unreserved, 0 to disable, or a positive number for reserved
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = merge(
      {
        ASPNETCORE_URLS = "http://+:8080"
        # Optimize .NET for Lambda
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"
        DOTNET_gcServer                       = "0"
      },
      var.environment_variables
    )
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

