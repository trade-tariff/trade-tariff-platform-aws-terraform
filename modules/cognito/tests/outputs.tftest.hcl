mock_provider "aws" {
  override_data {
    target = data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }

  # id and domain are computed, so they are unknown at plan without this.
  override_resource {
    target          = aws_cognito_user_pool.this
    override_during = plan
    values = {
      id     = "eu-west-2_AbCdEfGhI"
      domain = "test-pool-domain"
    }
  }

  override_resource {
    target          = aws_cognito_user_pool_domain.this
    override_during = plan
    values = {
      cloudfront_distribution_arn     = "arn:aws:cloudfront::123456789012:distribution/EDFDVBD6EXAMPLE"
      cloudfront_distribution_zone_id = "Z2FDTNDATAQYW2"
    }
  }
}

mock_provider "null" {}

variables {
  pool_name = "test-pool"

  # outputs.tf reads aws_cognito_user_pool_client.this[0] with no guard, so
  # every run must create the client. See the report for this bug.
  client_name = "test-client"
}

run "builds_public_keys_url_from_region_and_pool_id" {
  command = plan

  assert {
    condition     = output.user_pool_public_keys_url == "https://cognito-idp.eu-west-2.amazonaws.com/eu-west-2_AbCdEfGhI/.well-known/jwks.json"
    error_message = "user_pool_public_keys_url must be the JWKS URL for the pool in its region."
  }
}

run "builds_cognito_domain_without_certificate" {
  command = plan

  variables {
    domain = "test-pool-domain"
  }

  assert {
    condition     = output.domain == "test-pool-domain.auth.eu-west-2.amazoncognito.com"
    error_message = "domain must be the Cognito hosted domain when no certificate is given."
  }
}

run "uses_custom_domain_with_certificate" {
  command = plan

  variables {
    domain                 = "auth.example.com"
    domain_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = output.domain == "auth.example.com"
    error_message = "domain must be the custom domain when a certificate is given."
  }
}

run "exposes_cloudfront_details_when_domain_exists" {
  command = plan

  variables {
    domain = "test-pool-domain"
  }

  assert {
    condition     = output.cloudfront_distribution_arn == "arn:aws:cloudfront::123456789012:distribution/EDFDVBD6EXAMPLE"
    error_message = "cloudfront_distribution_arn must come from the domain when one is created."
  }

  assert {
    condition     = output.cloudfront_distribution_zone_id == "Z2FDTNDATAQYW2"
    error_message = "cloudfront_distribution_zone_id must come from the domain when one is created."
  }
}

run "has_null_cloudfront_details_without_domain" {
  command = plan

  assert {
    condition     = output.cloudfront_distribution_arn == null
    error_message = "cloudfront_distribution_arn must be null when no domain is created."
  }

  assert {
    condition     = output.cloudfront_distribution_zone_id == null
    error_message = "cloudfront_distribution_zone_id must be null when no domain is created."
  }
}
