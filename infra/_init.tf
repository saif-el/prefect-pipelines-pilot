terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "local" {
    path = "./terraform.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      "poc" = "prefect-pipelines"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
