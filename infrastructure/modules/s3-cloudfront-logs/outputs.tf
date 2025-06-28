# S3 CloudFront Logs Module Outputs
output "bucket" {
  description = "CloudFront logs S3 bucket resource"
  value       = module.logs_bucket.bucket
}

output "bucket_id" {
  description = "CloudFront logs S3 bucket ID"
  value       = module.logs_bucket.bucket_id
}

output "bucket_arn" {
  description = "CloudFront logs S3 bucket ARN"
  value       = module.logs_bucket.bucket_arn
}

output "bucket_name" {
  description = "CloudFront logs S3 bucket name"
  value       = module.logs_bucket.bucket_name
}

output "bucket_domain_name" {
  description = "CloudFront logs S3 bucket domain name"
  value       = module.logs_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "CloudFront logs S3 bucket regional domain name"
  value       = module.logs_bucket.bucket_regional_domain_name
}
