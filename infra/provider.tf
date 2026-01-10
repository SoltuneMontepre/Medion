terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "remote" {
    organization = var.organization

    workspaces {
      name = var.project_name
    }
  }
}