terraform {
  source = "../..//infra"
}
providers = {
  aws           = "aws"
  aws.us-east-1 = "aws.us-east-1"
}

locals {
  api_image              = get_env("api_image")
  app_env                = get_env("app_env")
  aws_license_plate      = get_env("aws_license_plate")
  command                = get_env("terrgrunt_command")
  db_cluster_name        = local.command == "plan" ? "" : "${local.stack_prefix}-aurora-${local.rds_app_env}"
  flyway_image           = get_env("flyway_image")
  rds_app_env            = (contains(["dev", "test", "prod"], "${local.app_env}") ? "${local.app_env}" : "dev") # if app_env is not dev, test, or prod, default to dev 
  region                 = "ca-central-1"
  repo_name              = get_env("repo_name")
  stack_prefix           = get_env("stack_prefix")
  statefile_bucket_name  = "${local.tf_remote_state_prefix}-${local.aws_license_plate}-${local.target_env}"
  statefile_key          = "${local.stack_prefix}/${local.app_env}/terraform.tfstate"
  target_env             = get_env("target_env")
  tf_remote_state_prefix = "terraform-remote-state" # Do not change this, given by cloud.pathfinder.
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
    use_lockfile   = true  # Enable native S3 locking
    encrypt        = true
  }
}
EOF
}

generate "tfvars" {
  path              = "terragrunt.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
  api_image="${local.api_image}"
  app_env="${local.app_env}"
  app_name="${local.stack_prefix}-node-api-${local.app_env}"
  db_cluster_name="${local.db_cluster_name}"
  flyway_image="${local.flyway_image}"
  repo_name = "${get_env("repo_name")}"
  target_env="${local.target_env}"
  common_tags = {
      "AppEnv"      = "${local.app_env}"
      "AppName"     = "${local.stack_prefix}-node-api-${local.app_env}"
      "Environment" = "${local.target_env}"
      "ManagedBy"   = "Terraform"
      "RepoName"    = "${get_env("repo_name")}"
    }
EOF
}
