terraform {
  
  backend "s3" {
  bucket       = "student-management-tfstate-716482800050"
  key          = "student-management/terraform.tfstate"
  region       = "us-east-1"
  use_lockfile = true
}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
}