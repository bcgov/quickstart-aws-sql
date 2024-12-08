module "network" {
  source      = "git::https://github.com/BCDevOps/terraform-octk-aws-sea-network-info.git//?ref=master"
  environment = var.target_env
}
data "aws_subnet" "a_app" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_app_a]
  }
}

data "aws_subnet" "b_app" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_app_b]
  }
}