output "domain_name" {
  value = var.domain_name
}

output "certificate_arn" {
  value = aws_acm_certificate.acm_certificate.arn
}

output "private_zone" {
  value = var.private_zone
}

output "validation_method" {
  value = var.validation_method
}
