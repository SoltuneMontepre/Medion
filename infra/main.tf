module "iam" {
  source = "./modules/iam"

  project_name = local.project_name
  github_org   = local.github_repo
}

module "api_gateway" {
  source = "./modules/api-gateway"

  project_name = local.project_name
  cors_origins = var.cors_origins
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = local.project_name

  repositories = {
    approval-api = {
      image_tag_mutability  = "MUTABLE"
      scan_on_push          = true
      lifecycle_policy_keep = 3
      lifecycle_expire_days = 7
    }
    identity-api = {
      image_tag_mutability  = "MUTABLE"
      scan_on_push          = true
      lifecycle_policy_keep = 3
      lifecycle_expire_days = 7
    }
    inventory-api = {
      image_tag_mutability  = "MUTABLE"
      scan_on_push          = true
      lifecycle_policy_keep = 3
      lifecycle_expire_days = 7
    }
    manufacture-api = {
      image_tag_mutability  = "MUTABLE"
      scan_on_push          = true
      lifecycle_policy_keep = 3
      lifecycle_expire_days = 7
    }
    payroll-api = {
      image_tag_mutability  = "MUTABLE"
      scan_on_push          = true
      lifecycle_policy_keep = 3
      lifecycle_expire_days = 7
    }
    sale-api = {
      image_tag_mutability  = "MUTABLE"
      scan_on_push          = true
      lifecycle_policy_keep = 3
      lifecycle_expire_days = 7
    }
  }
}

module "approval_service" {
  source = "./modules/microservice"

  service_name              = "approval"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["approval-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  jwt_audience              = local.jwt_audience
  jwt_issuer                = local.jwt_issuer

  no_auth_routes = [
    "/health/{proxy+}",
    "/health",
    "/swagger/{proxy+}",
    "/swagger",
  ]

  environment_variables = {
    ASPNETCORE_ENVIRONMENT      = "Production"
    CONNECTIONSTRINGS__POSTGRES = local.approval_db_url
    CONNECTIONSTRINGS__RABBITMQ = local.rabbitmq_connection_string
  }
}

module "sale_service" {
  source = "./modules/microservice"

  service_name              = "sale"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["sale-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  jwt_audience              = local.jwt_audience
  jwt_issuer                = local.jwt_issuer

  no_auth_routes = [
    "/health/{proxy+}",
    "/health",
    "/swagger/{proxy+}",
    "/swagger",
  ]

  environment_variables = {
    ASPNETCORE_ENVIRONMENT      = "Production"
    CONNECTIONSTRINGS__POSTGRES = local.sale_db_url
    CONNECTIONSTRINGS__RABBITMQ = local.rabbitmq_connection_string
    R2_ACCOUNT_ID               = local.r2_account_id
    R2_ACCESS_KEY               = local.r2_access_key
    R2_SECRET_KEY               = local.r2_secret_key
    R2_BUCKET_NAME              = local.r2_bucket_name
    R2_PUBLIC_ENDPOINT          = local.r2_public_endpoint
    R2_REGION                   = local.r2_region
  }
}

module "payroll_service" {
  source = "./modules/microservice"

  service_name              = "payroll"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["payroll-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  jwt_audience              = local.jwt_audience
  jwt_issuer                = local.jwt_issuer

  no_auth_routes = [
    "/health/{proxy+}",
    "/health",
    "/swagger/{proxy+}",
    "/swagger",
  ]

  environment_variables = {
    ASPNETCORE_ENVIRONMENT      = "Production"
    CONNECTIONSTRINGS__POSTGRES = local.payroll_db_url
    CONNECTIONSTRINGS__RABBITMQ = local.rabbitmq_connection_string
  }
}

module "inventory_service" {
  source = "./modules/microservice"

  service_name              = "inventory"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["inventory-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  jwt_audience              = local.jwt_audience
  jwt_issuer                = local.jwt_issuer

  no_auth_routes = [
    "/health/{proxy+}",
    "/health",
    "/swagger/{proxy+}",
    "/swagger",
  ]

  environment_variables = {
    ASPNETCORE_ENVIRONMENT      = "Production"
    CONNECTIONSTRINGS__POSTGRES = local.inventory_db_url
    CONNECTIONSTRINGS__RABBITMQ = local.rabbitmq_connection_string
  }
}

module "manufacture_service" {
  source = "./modules/microservice"

  service_name              = "manufacture"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["manufacture-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  jwt_audience              = local.jwt_audience
  jwt_issuer                = local.jwt_issuer

  no_auth_routes = [
    "/health/{proxy+}",
    "/health",
    "/swagger/{proxy+}",
    "/swagger",
  ]

  environment_variables = {
    ASPNETCORE_ENVIRONMENT      = "Production"
    CONNECTIONSTRINGS__POSTGRES = local.manufacture_db_url
    CONNECTIONSTRINGS__RABBITMQ = local.rabbitmq_connection_string
  }
}

module "identity_service" {
  source = "./modules/microservice"

  service_name              = "identity"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["identity-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  jwt_audience              = local.jwt_audience
  jwt_issuer                = local.jwt_issuer

  no_auth_routes = [
    "/health/{proxy+}",
    "/health",
    "/swagger/{proxy+}",
    "/swagger",
  ]

  environment_variables = {
    ASPNETCORE_ENVIRONMENT         = "Production"
    CONNECTIONSTRINGS__POSTGRES    = local.identity_db_url
    JwtSettings__Secret            = local.jwt_secret
    JwtSettings__Issuer            = local.jwt_issuer
    JwtSettings__Audience          = local.jwt_audience
    JwtSettings__ExpirationMinutes = local.jwt_expiration_minutes
  }
}

