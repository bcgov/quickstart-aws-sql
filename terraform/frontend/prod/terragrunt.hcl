include {
  path = find_in_parent_folders()
}
locals {
  app_env          = get_env("app_env")
  target_env              = get_env("target_env")
  
}

# Include the common terragrunt configuration for all modules
generate "prod_tfvars" {
  path              = "prod.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
  target_env = "prod"
EOF
}