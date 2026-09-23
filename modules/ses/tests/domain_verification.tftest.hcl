mock_provider "random" {}

mock_provider "aws" {
  # The identity id and the DKIM tokens are computed by AWS, so they are
  # unknown at plan time. These overrides give them fixed values.
  override_resource {
    target          = aws_ses_domain_identity.this
    override_during = plan
    values = {
      id                 = "trade-tariff.example.gov.uk"
      verification_token = "verification-token-value"
    }
  }

  override_resource {
    target          = aws_ses_domain_dkim.this
    override_during = plan
    values = {
      dkim_tokens = ["tokenone", "tokentwo", "tokenthree"]
    }
  }
}

variables {
  domain_name     = "trade-tariff.example.gov.uk"
  route53_zone_id = "Z0123456789ABCDEFGHIJ"
  email_receiver  = false
}

run "publishes_ses_verification_txt_record" {
  command = plan

  assert {
    condition     = aws_route53_record.this.name == "_amazonses.trade-tariff.example.gov.uk"
    error_message = "The verification record must be _amazonses.<domain>."
  }

  assert {
    condition     = aws_route53_record.this.type == "TXT"
    error_message = "The verification record must be a TXT record."
  }

  assert {
    condition     = aws_route53_record.this.records == toset(["verification-token-value"])
    error_message = "The verification record must contain the SES verification token."
  }
}

run "publishes_one_dkim_cname_per_token" {
  command = plan

  assert {
    condition     = length(aws_route53_record.dkim_record) == 3
    error_message = "The module must create three DKIM records, one for each SES DKIM token."
  }

  assert {
    condition     = [for record in aws_route53_record.dkim_record : record.name] == ["tokenone._domainkey", "tokentwo._domainkey", "tokenthree._domainkey"]
    error_message = "Each DKIM record must be named <token>._domainkey."
  }

  assert {
    condition     = alltrue([for record in aws_route53_record.dkim_record : record.type == "CNAME"])
    error_message = "Each DKIM record must be a CNAME record."
  }

  assert {
    condition     = aws_route53_record.dkim_record[1].records == toset(["tokentwo.dkim.amazonses.com"])
    error_message = "Each DKIM record must point to <token>.dkim.amazonses.com."
  }
}
