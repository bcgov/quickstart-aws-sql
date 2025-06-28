# CloudFront Origin Access Identity Module Variables
variable "comment" {
  description = "Comment for the Origin Access Identity"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket to grant access to"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to grant access to"
  type        = string
}
