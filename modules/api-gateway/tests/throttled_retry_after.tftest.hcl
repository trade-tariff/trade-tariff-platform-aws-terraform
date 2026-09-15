provider "aws" {
  region                      = "eu-west-2"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A 429 from the usage plan must tell the caller when to come back. The plan
# throttles with a token bucket refilling continuously at the steady-state
# rate, not a fixed window, so the bucket has room again within a second --
# advertising the WAF's 60 would park clients for a minute they need not wait.
run "throttled_response_carries_retry_after" {
  command = plan

  variables {
    environment               = "test"
    domain_name               = "example.test"
    validated_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    zone_id                   = "Z0000000000000000000"
    security_group_ids        = ["sg-00000000000000000"]
    private_subnet_ids        = ["subnet-00000000000000000", "subnet-11111111111111111"]
    lb_arn                    = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/app/test/0000000000000000"
    alb_secret_header         = ["X-Origin-Secret", "test-secret"]
  }

  assert {
    condition     = aws_api_gateway_gateway_response.throttled.response_parameters["gatewayresponse.header.Retry-After"] == "'1'"
    error_message = "a throttled 429 must carry Retry-After, quoted as an API Gateway static mapping value"
  }
}
