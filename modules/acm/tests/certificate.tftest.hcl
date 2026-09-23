mock_provider "aws" {}

# domain_validation_options is computed. The real provider knows it at plan,
# but the mock does not, and the route53 for_each needs its keys. So every
# run gives it a value here.
override_resource {
  target          = aws_acm_certificate.acm_certificate
  override_during = plan
  values = {
    arn = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    domain_validation_options = [
      {
        domain_name           = "dev.trade-tariff.service.gov.uk"
        resource_record_name  = "_a.dev.trade-tariff.service.gov.uk."
        resource_record_type  = "CNAME"
        resource_record_value = "_a.acm-validations.aws."
      },
      {
        domain_name           = "*.dev.trade-tariff.service.gov.uk"
        resource_record_name  = "_b.dev.trade-tariff.service.gov.uk."
        resource_record_type  = "CNAME"
        resource_record_value = "_b.acm-validations.aws."
      },
    ]
  }
}

variables {
  environment    = "development"
  domain_name    = "dev.trade-tariff.service.gov.uk"
  hosted_zone_id = "Z0000000000000000000"
}

run "adds_a_wildcard_name_to_the_certificate" {
  command = plan

  assert {
    condition     = aws_acm_certificate.acm_certificate.subject_alternative_names == toset(["*.dev.trade-tariff.service.gov.uk"])
    error_message = "The certificate must cover *.<domain_name> when no extra names are given."
  }

  assert {
    condition     = aws_acm_certificate.acm_certificate.validation_method == "DNS"
    error_message = "The certificate must use DNS validation."
  }

  assert {
    condition     = aws_acm_certificate.acm_certificate.tags["Environment"] == "development"
    error_message = "The certificate must be tagged with the environment."
  }
}

run "adds_extra_names_after_the_wildcard_name" {
  command = plan

  variables {
    subject_alternative_names = ["dev.trade-tariff.service.gov.uk.example"]
  }

  assert {
    condition = aws_acm_certificate.acm_certificate.subject_alternative_names == toset([
      "*.dev.trade-tariff.service.gov.uk",
      "dev.trade-tariff.service.gov.uk.example",
    ])
    error_message = "The certificate must cover the wildcard name and every extra name the caller gives."
  }
}

run "creates_one_validation_record_per_domain" {
  command = plan

  assert {
    condition     = toset(keys(aws_route53_record.route53_record)) == toset(["dev.trade-tariff.service.gov.uk", "*.dev.trade-tariff.service.gov.uk"])
    error_message = "One validation record must be created for each domain on the certificate."
  }

  assert {
    condition     = aws_route53_record.route53_record["*.dev.trade-tariff.service.gov.uk"].name == "_b.dev.trade-tariff.service.gov.uk."
    error_message = "The validation record name must come from the certificate validation option."
  }

  assert {
    condition     = aws_route53_record.route53_record["*.dev.trade-tariff.service.gov.uk"].records == toset(["_b.acm-validations.aws."])
    error_message = "The validation record value must come from the certificate validation option."
  }

  assert {
    condition     = aws_route53_record.route53_record["*.dev.trade-tariff.service.gov.uk"].type == "CNAME"
    error_message = "The validation record type must come from the certificate validation option."
  }

  assert {
    condition     = alltrue([for record in aws_route53_record.route53_record : record.zone_id == "Z0000000000000000000"])
    error_message = "Validation records must be created in the given hosted zone."
  }
}
