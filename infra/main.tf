module "iam" {
  source = "./modules/iam"

  project_name = local.projectName
  github_org   = local.githubRepository
}

module "api_gateway" {
  source = "./modules/api-gateway"

  project_name         = local.projectName
  cors_origins         = var.cors_origins
  auth_integration_uri = "http://${module.ec2.ec2_instance_public_dns}/api/auth"
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = local.projectName

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
  project_name              = local.projectName
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["approval-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn


  environment_variables = {
    aspnetcoreEnvironment = "Production"
    postgresApproval      = local.approvalDbUrl
    rabbitMq              = local.rabbitmqConnectionString
  }
}

module "sale_service" {
  source = "./modules/microservice"

  service_name              = "sale"
  project_name              = local.projectName
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["sale-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn

  environment_variables = {
    aspnetcoreEnvironment = "Production"
    postgresSale          = local.saleDbUrl
    rabbitMq              = local.rabbitmqConnectionString
    r2AccountId           = local.r2AccountId
    r2AccessKey           = local.r2AccessKey
    r2SecretKey           = local.r2SecretKey
    r2BucketName          = local.r2BucketName
    r2PublicEndpoint      = local.r2PublicEndpoint
    r2Region              = local.r2Region
  }
}

module "payroll_service" {
  source = "./modules/microservice"

  service_name              = "payroll"
  project_name              = local.projectName
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["payroll-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn

  environment_variables = {
    aspnetcoreEnvironment = "Production"
    postgresPayroll       = local.payrollDbUrl
    rabbitMq              = local.rabbitmqConnectionString
  }
}

module "inventory_service" {
  source = "./modules/microservice"

  service_name              = "inventory"
  project_name              = local.projectName
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["inventory-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn

  environment_variables = {
    aspnetcoreEnvironment = "Production"
    postgresInventory     = local.inventoryDbUrl
    rabbitMq              = local.rabbitmqConnectionString
  }
}

module "manufacture_service" {
  source = "./modules/microservice"

  service_name              = "manufacture"
  project_name              = local.projectName
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["manufacture-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  environment_variables = {
    aspnetcoreEnvironment = "Production"
    postgresManufacture   = local.manufactureDbUrl
    rabbitMq              = local.rabbitmqConnectionString
  }
}

module "security_service" {
  source = "./modules/microservice"

  service_name              = "security"
  project_name              = local.projectName
  lambda_role_arn           = module.iam.lambda_execution_role.arn
  ecr_repository            = module.ecr.repository_urls["security-api"]
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn


  environment_variables = {
    aspnetcoreEnvironment      = "Production"
    postgresSecurity           = local.securityDbUrl
    jwtSettingsSecret          = local.jwtSecret
    jwtSettingsIssuer          = local.jwtIssuer
    jwtSettingsAudience        = local.jwtAudience
    jwtSettingsExpirationMinutes = local.jwtExpirationMinutes
  }
}

module "ec2" {
  source = "./modules/ec2"
}
