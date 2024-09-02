output "domain_name" {
  value = var.domain_name
}

output "validated_certificate_arn" {
  description = "Validated certificate ARN for use with other resources."
  value       = aws_acm_certificate_validation.validate_acm_certificates.certificate_arn
}
