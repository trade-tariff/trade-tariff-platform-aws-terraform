module "waf" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/waf?ref=ce48dd19135b89b85d8227ac5b6bd830a4b6676b"

  name  = "tariff-waf-${var.environment}"
  scope = "CLOUDFRONT"
  ip_rate_based_rule = {
    name      = "ratelimiting"
    priority  = 1
    rpm_limit = var.waf_rpm_limit
    action    = "block"
    custom_response = {
      response_code = 429
      body_key      = "rate-limit-exceeded"
      response_header = {
        name  = "X-Rate-Limit"
        value = "1"
      }
    }
  }
}
