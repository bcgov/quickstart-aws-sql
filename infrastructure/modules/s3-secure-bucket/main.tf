# S3 Secure Bucket Module Main Configuration
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_algorithm
    }
  }
}

# Public access block configuration
resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.enable_public_access_block ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [rule.value.expiration_days] : []
        content {
          days = expiration.value
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition_rules != null ? rule.value.transition_rules : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

# Bucket policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      try(jsondecode(var.bucket_policy).Statement, []),
      [
        {
          Sid = "DenyUnencryptedObjectUploads"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource  = [
            "arn:aws:s3:::${var.bucket_name}",
            "arn:aws:s3:::${var.bucket_name}/*"
          ]
          Condition = {
            Bool = {
              "aws:SecureTransport" = false
            }
          }
        }
      ]
    )
  })
}
