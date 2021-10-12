terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure Provider for CloudWatch since only us-east-1 is supported
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}