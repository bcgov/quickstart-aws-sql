# CloudFront Module Main Configuration
resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = "Distribution for ${var.app_name} ${var.distribution_type} from github repository :: ${var.repo_name}"
  default_root_object = var.distribution_type == "s3" ? var.default_root_object : null
  price_class         = var.price_class
  web_acl_id          = var.web_acl_arn
  aliases             = var.aliases

  # Conditional logging configuration
  dynamic "logging_config" {
    for_each = var.enable_logging && var.log_bucket_domain_name != null ? [1] : []
    content {
      include_cookies = var.log_include_cookies
      bucket          = var.log_bucket_domain_name
      prefix          = var.log_prefix
    }
  }

  # S3 Origin Configuration
  dynamic "origin" {
    for_each = var.distribution_type == "s3" ? [1] : []
    content {
      domain_name = var.s3_origin_domain_name
      origin_id   = var.s3_origin_id

      s3_origin_config {
        origin_access_identity = var.s3_origin_access_identity_path
      }
    }
  }

  # API Origin Configuration
  dynamic "origin" {
    for_each = var.distribution_type == "api" ? [1] : []
    content {
      domain_name = var.api_origin_domain_name
      origin_id   = var.api_origin_id

      custom_origin_config {
        origin_protocol_policy = var.api_origin_protocol_policy
        http_port              = var.api_origin_http_port
        https_port             = var.api_origin_https_port
        origin_ssl_protocols   = var.api_origin_ssl_protocols
      }
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods  = var.cache_allowed_methods
    cached_methods   = var.cache_cached_methods
    target_origin_id = var.distribution_type == "s3" ? var.s3_origin_id : var.api_origin_id
    
    viewer_protocol_policy = var.cache_viewer_protocol_policy
    min_ttl                = var.cache_min_ttl
    default_ttl            = var.cache_default_ttl
    max_ttl                = var.cache_max_ttl

    forwarded_values {
      query_string = var.cache_forward_query_string

      cookies {
        forward = var.cache_forward_cookies
      }
    }
  }

  # Geo Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # SSL Certificate Configuration
  viewer_certificate {
    cloudfront_default_certificate = var.use_cloudfront_default_certificate
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn != null ? var.ssl_support_method : null
    minimum_protocol_version       = var.acm_certificate_arn != null ? var.minimum_protocol_version : null
  }
  dynamic "custom_error_response" {
    for_each = var.distribution_type == "s3" ? [1] : []
    content {
      error_code = 403
      response_code = 200
      response_page_path = "/"
    }
  }

  tags = var.tags
}
