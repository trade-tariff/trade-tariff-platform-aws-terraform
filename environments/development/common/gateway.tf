module "gateway" {
  source = "../../../modules/api-gateway"

  environment                      = var.environment
  domain_name                      = var.domain_name
  validated_certificate_arn        = module.acm_london.validated_certificate_arn
  zone_id                          = data.aws_route53_zone.this.zone_id
  security_group_ids               = [module.alb-security-group.alb_security_group_id]
  private_subnet_ids               = data.terraform_remote_state.base.outputs.private_subnet_ids
  lb_arn                           = module.alb.lb_arn
  cache_cluster_enabled            = true
  cache_cluster_size               = "0.5"
  log_level                        = "INFO"
  authorizer_enabled               = true
  authorizer_name                  = "api-authorizer-${var.environment}"
  authorizer_lambda_invoke_arn     = data.aws_lambda_function.api_gateway_authorizer.invoke_arn
  authorizer_identity_source       = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 0

  alb_secret_header = [
    random_password.origin_header[0].result,
    random_password.origin_header[1].result
  ]
}

############################################
# Usage Plan
############################################

variable "apigw_default_rate_limit" {
  description = "Steady-state requests per second for usage plan"
  type        = number
  default     = 8 # 500 requests / 60 seconds
}

variable "apigw_default_burst_limit" {
  description = "Burst limit for usage plan"
  type        = number
  default     = 16
}

# Usage plan linked to THIS environment's deployed stage
resource "aws_api_gateway_usage_plan" "default" {
  name        = "standard-${var.environment}"
  description = "Standard usage plan for ${var.environment}"

  throttle_settings {
    burst_limit = var.apigw_default_burst_limit
    rate_limit  = var.apigw_default_rate_limit
  }

  api_stages {
    api_id = module.gateway.rest_api_id
    stage  = module.gateway.stage_name
  }
}
