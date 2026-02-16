module "gateway" {
  source = "../../../modules/api-gateway"

  environment               = var.environment
  domain_name               = var.domain_name
  validated_certificate_arn = module.acm_london.validated_certificate_arn
  zone_id                   = data.aws_route53_zone.this.zone_id
  security_group_ids        = [module.alb-security-group.alb_security_group_id]
  private_subnet_ids        = data.terraform_remote_state.base.outputs.private_subnet_ids
  lb_arn                    = module.alb.lb_arn
  cache_cluster_enabled     = true
  cache_cluster_size        = "0.5"
  log_level                 = "INFO"

  alb_secret_header = [
    random_password.origin_header[0].result,
    random_password.origin_header[1].result
  ]
}

############################################
# Minimal API Key + Usage Plan
############################################

variable "apigw_default_rate_limit" {
  description = "Steady-state requests per second for usage plan"
  type        = number
  default     = 50
}

variable "apigw_default_burst_limit" {
  description = "Burst limit for usage plan"
  type        = number
  default     = 100
}

# Generate a random API key value at apply time (do not hardcode)
resource "random_id" "apigw_test_key" {
  byte_length = 32
}

resource "aws_api_gateway_api_key" "internal_test" {
  name        = "internal-test-${var.environment}"
  description = "Internal testing key for ${var.environment}"

  # Use generated value (lowercase hex)
  value = lower(random_id.apigw_test_key.hex)
}

resource "aws_secretsmanager_secret_version" "apigw_internal_test_key_value" {
  secret_id     = module.apigw_internal_test_key.secret_arn
  secret_string = aws_api_gateway_api_key.internal_test.value
}

# Usage plan linked to THIS environment's deployed stage
resource "aws_api_gateway_usage_plan" "default" {
  name        = "default-${var.environment}"
  description = "Default internal usage plan for ${var.environment}"

  throttle_settings {
    burst_limit = var.apigw_default_burst_limit
    rate_limit  = var.apigw_default_rate_limit
  }

  api_stages {
    api_id = module.gateway.rest_api_id
    stage  = module.gateway.stage_name
  }
}

# Attach the key to the usage plan
resource "aws_api_gateway_usage_plan_key" "internal_test_attach" {
  key_id        = aws_api_gateway_api_key.internal_test.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}
