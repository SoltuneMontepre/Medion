data "doppler_secrets" "this" {
  config  = var.doppler_config
  project = var.doppler_project
}

locals {
  projectName = data.doppler_secrets.this.map.PROJECT_NAME

  ## AWS Credentials
  awsAccessKeyId     = data.doppler_secrets.this.map.AWS_ACCESS_KEY_ID
  awsSecretAccessKey = data.doppler_secrets.this.map.AWS_SECRET_ACCESS_KEY

  ## GitHub OIDC
  githubRepository = data.doppler_secrets.this.map.GITHUB_REPOSITORY

  ## Database URLs
  approvalDbUrl    = data.doppler_secrets.this.map.APPROVAL_DB_URL
  payrollDbUrl     = data.doppler_secrets.this.map.PAYROLL_DB_URL
  inventoryDbUrl   = data.doppler_secrets.this.map.INVENTORY_DB_URL
  manufactureDbUrl = data.doppler_secrets.this.map.MANUFACTURE_DB_URL
  saleDbUrl        = data.doppler_secrets.this.map.SALE_DB_URL
  securityDbUrl    = data.doppler_secrets.this.map.IDENTITY_DB_URL

  ## Message Queue
  rabbitmqConnectionString = data.doppler_secrets.this.map.RABBITMQ_URL

  ## Cloudflare R2 Storage
  r2AccountId      = data.doppler_secrets.this.map.R2_ACCOUNT_ID
  r2AccessKey      = data.doppler_secrets.this.map.R2_ACCESS_KEY
  r2SecretKey      = data.doppler_secrets.this.map.R2_SECRET_KEY
  r2BucketName     = data.doppler_secrets.this.map.R2_BUCKET_NAME
  r2PublicEndpoint = data.doppler_secrets.this.map.R2_PUBLIC_ENDPOINT
  r2Region         = data.doppler_secrets.this.map.R2_REGION

  ## JWT Settings (Identity Service)
  jwtSecret             = data.doppler_secrets.this.map.JWT_SECRET
  jwtIssuer             = data.doppler_secrets.this.map.JWT_ISSUER
  jwtAudience           = data.doppler_secrets.this.map.JWT_AUDIENCE
  jwtExpirationMinutes  = data.doppler_secrets.this.map.JWT_EXPIRATION_MINUTES
}
