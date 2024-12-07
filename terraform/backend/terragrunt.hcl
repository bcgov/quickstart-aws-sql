terraform {
  source = "../../..//infrastructure//backend"
}



locals {
  region                  = "ca-central-1"

  # Terraform remote S3 config
  tf_remote_state_prefix  = "terraform-remote-state" # Do not change this, given by cloud.pathfinder.
  target_env              = get_env("target_env")
  statefile_bucket_name   = "${local.tf_remote_state_prefix}-qsawsc-${local.target_env}" 
  statefile_key           = "server.tfstate"
  statelock_table_name    = "${local.tf_remote_state_prefix}-lock-qsawsc-${local.target_env}" 
}

# Remote S3 state for Terraform.
generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "${local.statefile_bucket_name}"
    key            = "${local.statefile_key}"            # Path and name of the state file within the bucket
    region         = "${local.region}"                    # AWS region where the bucket is located
    dynamodb_table = "${local.statelock_table_name}"
    encrypt        = true
  }
}
EOF
}
resource "aws_s3_bucket" "statefile_bucket" {
  bucket = "${local.statefile_bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Terraform state bucket"
    Environment = "${local.target_env}"
  }
}

resource "aws_dynamodb_table" "statefile_lock" {
  name         = "${local.statelock_table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform state lock table"
    Environment = "${local.target_env}"
  }
}

generate "tfvars" {
  path              = "terragrunt.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region  = "${local.region}"
}
EOF
}