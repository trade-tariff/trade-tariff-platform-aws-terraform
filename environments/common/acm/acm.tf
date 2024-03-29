/* ssl certificate resource */
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = concat(["*.${var.domain_name}"], var.subject_alternative_names)

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.environment
  }
}

/* create a record set for route53 for domain validation */
resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

/*validate acm certificates */
resource "aws_acm_certificate_validation" "validate_acm_certificates" {
  certificate_arn = aws_acm_certificate.acm_certificate.arn

  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
  timeouts {
    create = var.validation_timeout
  }
}
