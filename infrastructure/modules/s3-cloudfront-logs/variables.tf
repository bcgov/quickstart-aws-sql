# S3 CloudFront Logs Module Variables
variable "bucket_name" {
  description = "Name of the CloudFront logs bucket"
  type        = string
}

variable "log_prefix" {
  description = "Prefix for CloudFront logs"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS Account ID for bucket policy"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
