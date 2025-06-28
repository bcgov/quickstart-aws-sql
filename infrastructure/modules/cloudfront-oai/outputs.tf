# CloudFront OAI Module Outputs
output "oai" {
  description = "CloudFront Origin Access Identity information"
  value = {
    id                              = aws_cloudfront_origin_access_identity.this.id
    arn                             = aws_cloudfront_origin_access_identity.this.arn
    caller_reference               = aws_cloudfront_origin_access_identity.this.caller_reference
    cloudfront_access_identity_path = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    etag                           = aws_cloudfront_origin_access_identity.this.etag
    iam_arn                        = aws_cloudfront_origin_access_identity.this.iam_arn
    s3_canonical_user_id           = aws_cloudfront_origin_access_identity.this.s3_canonical_user_id
  }
}

output "oai_id" {
  description = "CloudFront Origin Access Identity ID"
  value       = aws_cloudfront_origin_access_identity.this.id
}

output "oai_arn" {
  description = "CloudFront Origin Access Identity ARN"
  value       = aws_cloudfront_origin_access_identity.this.arn
}

output "oai_cloudfront_access_identity_path" {
  description = "CloudFront access identity path for S3 origin configuration"
  value       = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
}

output "oai_iam_arn" {
  description = "IAM ARN for the Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.this.iam_arn
}
