terraform {
  required_version = ">= 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  alias  = "Canada-Central-1"
  region = "ca-central-1"
}
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}