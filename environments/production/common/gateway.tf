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
  cache_cluster_size               = "1.6"
  log_level                        = "INFO"
  authorizer_enabled               = true
  authorizer_name                  = "api-authorizer-${var.environment}"
  authorizer_lambda_invoke_arn     = data.aws_lambda_function.api_gateway_authorizer.invoke_arn
  authorizer_identity_source       = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 0
  access_logging_enabled           = true
  cloudwatch_role_arn              = aws_iam_role.apigw_cloudwatch_logs.arn

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
  default     = 13
}

variable "apigw_default_burst_limit" {
  description = "Burst limit for usage plan"
  type        = number
  default     = 25
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
# 50 rps x 60 = 3,000 rpm. Tunable: mcp-tariff-api-approaching-rate-limit-<env>
# fires at 80% of it, and the number is meant to be reviewed against real usage.
variable "mcp_rate_limit" {
  description = "Steady-state requests per second for the shared MCP usage plan. 50 rps = 3,000 rpm."
  type        = number
  default     = 50
}

variable "mcp_burst_limit" {
  description = "Burst limit for the shared MCP usage plan."
  type        = number
  default     = 100
}

# Terraform owns both shared MCP values, so they cannot drift between the
# repos that use them. The authenticator reads MCP_SECRET_TOKEN and
# MCP_USAGE_KEY from mcp-shared-credentials when it deploys, and the MCP server
# reads MCP_SECRET_TOKEN from it.
#
# To rotate, replace both random_password resources, then deploy the
# authenticator and the MCP server straight after. Until both are deployed
# again, the MCP server sends the old token, the authenticator accepts it and
# returns the old usage key, and that key no longer exists, so each MCP request
# gets a 403.
resource "random_password" "mcp_secret_token" {
  count   = var.mcp_enabled ? 1 : 0
  length  = 64
  special = false
}

# API Gateway accepts key values of 20 to 128 characters.
resource "random_password" "mcp_usage_plan_key" {
  count   = var.mcp_enabled ? 1 : 0
  length  = 40
  special = false
}

# The secret always has a value, so the consumers can always read it. When
# mcp_enabled is false, both values are empty, and the authorizer and the MCP
# server treat an empty value as "MCP is off".
module "mcp_shared_credentials" {
  source          = "../../../modules/secret/"
  name            = "mcp-shared-credentials"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7

  secret_string = jsonencode({
    MCP_SECRET_TOKEN = var.mcp_enabled ? random_password.mcp_secret_token[0].result : ""
    MCP_USAGE_KEY    = var.mcp_enabled ? random_password.mcp_usage_plan_key[0].result : ""
  })
}

resource "aws_api_gateway_api_key" "mcp" {
  count       = var.mcp_enabled ? 1 : 0
  name        = "mcp-${var.environment}"
  description = "Shared key for MCP server traffic (HMRC-2699)"
  value       = random_password.mcp_usage_plan_key[0].result
}

resource "aws_api_gateway_usage_plan" "mcp" {
  count       = var.mcp_enabled ? 1 : 0
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
  count         = var.mcp_enabled ? 1 : 0
  key_id        = aws_api_gateway_api_key.mcp[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.mcp[0].id
}
