# S3 Secure Bucket Module Variables
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Force destroy bucket contents on deletion"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "enable_public_access_block" {
  description = "Enable public access block settings"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id                = string
    enabled           = bool
    expiration_days   = optional(number)
    transition_rules  = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

variable "bucket_policy" {
  description = "Optional bucket policy JSON"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
