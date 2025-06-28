# S3 Secure Bucket Module Outputs
output "bucket" {
  description = "S3 bucket resource"
  value       = aws_s3_bucket.this
}

output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "S3 bucket hosted zone ID"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "bucket_region" {
  description = "S3 bucket region"
  value       = aws_s3_bucket.this.region
}
