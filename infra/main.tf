module "iam" {
  source = "./modules/iam"

  project_name = local.project_name
  github_org   = local.github_repo
}

module "api_gateway" {
  source = "./modules/api-gateway"

  project_name         = local.project_name
  cors_origins         = var.cors_origins
  auth_integration_uri = "http://${module.ec2.ec2_instance_public_dns}/api/auth"
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
    security-api = {
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


  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    postgres_approval      = local.approval_db_url
    rabbitmq               = local.rabbitmq_connection_string
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

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    postgres_sale          = local.sale_db_url
    rabbitmq               = local.rabbitmq_connection_string
    R2_ACCOUNT_ID          = local.r2_account_id
    R2_ACCESS_KEY          = local.r2_access_key
    R2_SECRET_KEY          = local.r2_secret_key
    R2_BUCKET_NAME         = local.r2_bucket_name
    R2_PUBLIC_ENDPOINT     = local.r2_public_endpoint
    R2_REGION              = local.r2_region
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

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    postgres_payroll       = local.payroll_db_url
    rabbitmq               = local.rabbitmq_connection_string
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

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    postgres_inventory     = local.inventory_db_url
    rabbitmq               = local.rabbitmq_connection_string
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
  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    postgres_manufacture   = local.manufacture_db_url
    rabbitmq               = local.rabbitmq_connection_string
  }
}

module "security_service" {
  source = "./modules/microservice"

  service_name              = "security"
  project_name              = local.project_name
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["security-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn


  environment_variables = {
    ASPNETCORE_ENVIRONMENT        = "Production"
    postgres_security             = local.security_db_url
    JwtSettings__Secret           = local.jwt_secret
    JwtSettings__Issuer           = local.jwt_issuer
    JwtSettings__Audience         = local.jwt_audience
    JwtSettings__ExpirationMinutes = local.jwt_expiration_minutes
  }
}

module "ec2" {
  source = "./modules/ec2"
}
