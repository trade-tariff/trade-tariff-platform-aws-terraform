module "waf" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/waf?ref=6fec05665ea4ccc8b5c22977743bd68cc3d8d7da"

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
