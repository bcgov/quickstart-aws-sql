output "cloudfront" {
  description = "CloudFront distribution."
  value = {
    domain_name     = aws_cloudfront_distribution.s3_distribution.domain_name
    distribution_id = aws_cloudfront_distribution.s3_distribution.id
    url= "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
  }
}

output "s3_bucket_arn" {
  description = "ARN of S3 bucket for storing static assets."
  value       = aws_s3_bucket.frontend.arn
}