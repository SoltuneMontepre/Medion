data "doppler_secrets" "this" {
  config  = var.doppler_config
  project = var.doppler_project
}

locals {
  project_name = data.doppler_secrets.this.map.PROJECT_NAME

  ## AWS Credentials
  aws_access_key_id     = data.doppler_secrets.this.map.AWS_ACCESS_KEY_ID
  aws_secret_access_key = data.doppler_secrets.this.map.AWS_SECRET_ACCESS_KEY

  ## GitHub OIDC
  github_repo = data.doppler_secrets.this.map.GITHUB_REPOSITORY

  ## Database URLs
  approval_db_url    = data.doppler_secrets.this.map.APPROVAL_DB_URL
  payroll_db_url     = data.doppler_secrets.this.map.PAYROLL_DB_URL
  inventory_db_url   = data.doppler_secrets.this.map.INVENTORY_DB_URL
  manufacture_db_url = data.doppler_secrets.this.map.MANUFACTURE_DB_URL
  sale_db_url        = data.doppler_secrets.this.map.SALE_DB_URL
  security_db_url    = data.doppler_secrets.this.map.IDENTITY_DB_URL  # TODO: Rename to SECURITY_DB_URL in Doppler

  ## Message Queue
  rabbitmq_connection_string = data.doppler_secrets.this.map.RABBITMQ_URL

  ## Cloudflare R2 Storage
  r2_account_id      = data.doppler_secrets.this.map.R2_ACCOUNT_ID
  r2_access_key      = data.doppler_secrets.this.map.R2_ACCESS_KEY
  r2_secret_key      = data.doppler_secrets.this.map.R2_SECRET_KEY
  r2_bucket_name     = data.doppler_secrets.this.map.R2_BUCKET_NAME
  r2_public_endpoint = data.doppler_secrets.this.map.R2_PUBLIC_ENDPOINT
  r2_region          = data.doppler_secrets.this.map.R2_REGION

  ## JWT Settings (Identity Service)
  jwt_secret             = data.doppler_secrets.this.map.JWT_SECRET
  jwt_issuer             = data.doppler_secrets.this.map.JWT_ISSUER
  jwt_audience           = data.doppler_secrets.this.map.JWT_AUDIENCE
  jwt_expiration_minutes = data.doppler_secrets.this.map.JWT_EXPIRATION_MINUTES
}
