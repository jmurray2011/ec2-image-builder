terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.18.1"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"

  default_tags {
    tags = {
      Environment   = "personal"
      Service       = "testing"
      ManagedBy     = "ec2-image-builder Terraform Repo"
      ManagedByTeam = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}