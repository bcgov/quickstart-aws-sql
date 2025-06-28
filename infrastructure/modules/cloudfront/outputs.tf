# CloudFront Module Outputs
output "distribution" {
  description = "CloudFront distribution information"
  value = {
    id                    = aws_cloudfront_distribution.this.id
    arn                   = aws_cloudfront_distribution.this.arn
    domain_name           = aws_cloudfront_distribution.this.domain_name
    status                = aws_cloudfront_distribution.this.status
    hosted_zone_id        = aws_cloudfront_distribution.this.hosted_zone_id
    etag                  = aws_cloudfront_distribution.this.etag
    caller_reference      = aws_cloudfront_distribution.this.caller_reference
  }
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_url" {
  description = "CloudFront distribution HTTPS URL"
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}
