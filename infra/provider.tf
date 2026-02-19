provider "doppler" {
}

provider "aws" {
  region     = var.aws_region
  access_key = local.awsAccessKeyId
  secret_key = local.awsSecretAccessKey

  default_tags {
    tags = {
      Project   = local.projectName
      ManagedBy = "Terraform"
    }
  }
}
