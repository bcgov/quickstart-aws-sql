# CloudFront Origin Access Identity Module Main Configuration
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.comment
}

# S3 bucket policy to allow OAI access
resource "aws_s3_bucket_policy" "oai_policy" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.this.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}
