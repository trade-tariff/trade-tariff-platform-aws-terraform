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
  default     = 3 # Requests per second
}

variable "apigw_default_burst_limit" {
  description = "Burst limit for usage plan"
  type        = number
  default     = 6
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

############################################
# MCP Usage Plan (HMRC-2699)
############################################

# MCP traffic shares one ceiling instead of consuming each end user's plan:
# DevHub issues a key per developer, which breaks for organisations on a
# corporate setup sharing one key. The authorizer returns
# aws_api_gateway_api_key.mcp's value as the usageIdentifierKey for requests
# presenting a valid X-Mcp-Token, so they land here.
#
# Development's defaults below are 5 rps x 60 = 300 rpm -- deliberately much
# lower than staging/production's 3,000 rpm -- so a burst of MCP traffic here
# visibly hits the shared plan instead of blending in with the per-user plan
# (see Task 7 Step 5 of the rollout plan). Tunable:
# mcp-tariff-api-approaching-rate-limit-<env> fires at 80% of whatever this
# environment's limit is, and the production number is meant to be reviewed
# against real usage.
variable "mcp_rate_limit" {
  description = "Steady-state requests per second for the shared MCP usage plan. Deliberately low in development so the shared plan is observably different from the per-user one."
  type        = number
  default     = 5
}

variable "mcp_burst_limit" {
  description = "Burst limit for the shared MCP usage plan."
  type        = number
  default     = 10
}

resource "aws_api_gateway_api_key" "mcp" {
  count       = var.mcp_usage_plan_key != "" ? 1 : 0
  name        = "mcp-${var.environment}"
  description = "Shared key for MCP server traffic (HMRC-2699)"
  value       = var.mcp_usage_plan_key
}

resource "aws_api_gateway_usage_plan" "mcp" {
  count       = var.mcp_usage_plan_key != "" ? 1 : 0
  name        = "mcp-${var.environment}"
  description = "Global rate limit for all MCP server traffic in ${var.environment}"

  throttle_settings {
    burst_limit = var.mcp_burst_limit
    rate_limit  = var.mcp_rate_limit
  }

  api_stages {
    api_id = module.gateway.rest_api_id
    stage  = module.gateway.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "mcp" {
  count         = var.mcp_usage_plan_key != "" ? 1 : 0
  key_id        = aws_api_gateway_api_key.mcp[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.mcp[0].id
}
