# S3 CloudFront Logs Module Main Configuration
data "aws_caller_identity" "current" {}

# Use the secure bucket module for the base configuration
module "logs_bucket" {
  source = "../s3-secure-bucket"
  
  bucket_name                = var.bucket_name
  force_destroy              = true
  enable_encryption          = true
  encryption_algorithm       = "AES256"
  enable_public_access_block = true
  enable_versioning          = false
  tags                       = var.tags
  
  # CloudFront logs bucket policy
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipalPutObject"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "arn:aws:s3:::${var.bucket_name}${var.log_prefix != "" ? "/${var.log_prefix}" : ""}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id != null ? var.account_id : data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid = "AllowCloudFrontServicePrincipalGetBucketAcl"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${var.bucket_name}"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id != null ? var.account_id : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
