# WAF Module Outputs
output "web_acl" {
  description = "WAF Web ACL information"
  value = {
    id           = aws_wafv2_web_acl.this.id
    arn          = aws_wafv2_web_acl.this.arn
    name         = aws_wafv2_web_acl.this.name
    description  = aws_wafv2_web_acl.this.description
    scope        = aws_wafv2_web_acl.this.scope
  }
}

output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.this.name
}
