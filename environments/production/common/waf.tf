resource "aws_wafv2_ip_set" "tss_scraper_cf" {
  provider           = aws.us_east_1
  name               = "tss-scraper-cf-${var.environment}"
  description        = "TSS Tariff Scraper and GistWorld rate limit exception, remove after 2027-01-01, HMRC-2501, HMRC-2733"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = [var.tss_scraper_ip, var.gistworld_ip]
}

locals {
  # X-Api-Key values are UUIDs (see GREEN_LANES_API_KEYS in the
  # backend-xi-api-configuration secret). This is a format check, not a
  # validity check against the real keys: it keeps credential material out of
  # the WAF entirely, and the application remains the only place that decides
  # whether a key is genuine and enforces its per-key limit/period. Forging a
  # UUID-shaped header only buys the higher WAF tier, not access.
  api_key_header_regex = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
}

module "waf" {
  source = "../../../modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  name  = "tariff-waf-${var.environment}"
  scope = "CLOUDFRONT"

  ip_rate_based_rule = {
    name      = "ratelimiting"
    priority  = 4
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

  # Pins each IP in the TSS set (TSS and GistWorld, HMRC-2733) at exactly 500
  # RPM regardless of what var.waf_rpm_limit becomes. allow-tss-scraper
  # (ip_sets_rule below) bypasses the lower general limit.
  # Remove this rule and allow-tss-scraper after 2027-01-01 (HMRC-2501).
  ip_set_rate_based_rules = [
    {
      name       = "tss-scraper-rate-limit"
      priority   = 1
      limit      = 500
      action     = "block"
      ip_set_arn = aws_wafv2_ip_set.tss_scraper_cf.arn
      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"
        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    }
  ]

  ip_sets_rule = [
    {
      name       = "allow-tss-scraper"
      priority   = 2
      ip_set_arn = aws_wafv2_ip_set.tss_scraper_cf.arn
      action     = "allow"
    }
  ]

  # Two-tier rate limiting. Clients presenting a UUID-shaped X-Api-Key stay on
  # the "ratelimiting" rule above (var.waf_rpm_limit); everyone else is also
  # held to the lower var.waf_no_api_key_rpm_limit here.
  #
  # The negation lives in a separate labelling rule because AWS WAF rejects
  # not_statement inside a rate-based scope_down_statement. label-no-api-key
  # uses a non-terminating count action, so it tags the request and evaluation
  # carries on; a terminating allow would let anyone sending the header skip
  # the managed rule groups (SQLi, bot control) as well as the rate limit.
  #
  # Priorities 11/12 sit after the allow rules at 0-10, so the MCP, TSS, e2e,
  # healthcheck and mycommodities bypasses all keep taking precedence.
  #
  # Unkeyed traffic is blocked at var.waf_no_api_key_rpm_limit, which is lower
  # than the var.waf_rpm_limit that keyed clients get from the "ratelimiting"
  # rule above.
  header_regex_label_rules = [
    {
      name         = "label-no-api-key"
      priority     = 11
      header_name  = "x-api-key"
      regex_string = local.api_key_header_regex
      label        = "no-api-key"
      negate       = true
    }
  ]

  # Non-browser TLS clients on HTML page paths (HMRC-2724).
  #
  # Characters 9 and 10 of the first JA4 part (t13d1811"00") are the ALPN
  # value. "00" means that the client sent no ALPN. Real browsers always send
  # ALPN (h2), so a client with "00" that claims a browser User-Agent is a
  # script. The 1 Oct 2026 scraper used t13d181100_85036bcba153_d41ae481755e
  # from 31 IPs.
  #
  # label-no-alpn-pages labels these requests. ratelimiting-no-alpn-pages
  # (below) then counts them per JA4 fingerprint, not per IP, so the limit
  # applies however many IPs a bot uses. Real users never see a CAPTCHA or
  # challenge from this: the only action is a 429 above the limit.
  #
  # The path regex covers the tariff browse and search pages, with the
  # optional /uk/ or /xi/ prefix. It does not match /api/, /uk/api/,
  # /xi/api/ or /healthcheck. The allow rules at priorities 0-10 (MCP, TSS,
  # assets, e2e, healthcheck, mycommodities) come first, so they still apply.
  ja4_path_label_rules = [
    {
      name              = "label-no-alpn-pages"
      priority          = 13
      ja4_regex_string  = "^[tqd][0-9a-z]{2}[di][0-9]{4}00_"
      path_regex_string = "^/(uk/|xi/)?(sections|chapters|headings|subheadings|commodities|search|find_commodity|browse)(/|$)"
      label             = "no-alpn-page"
    }
  ]

  label_rate_based_rules = [
    {
      name     = "ratelimiting-no-api-key"
      priority = 12
      limit    = var.waf_no_api_key_rpm_limit
      action   = "block"
      label    = "no-api-key"
      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"
        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    },
    # Starts in count mode (HMRC-2724).
    #
    # The counter is per JA4 fingerprint, not per client. Every client with
    # the same fingerprint shares one budget of
    # var.waf_no_alpn_page_rpm_limit, including real users behind a
    # TLS-inspection proxy. Before you change action to "block", examine the
    # sampled requests and WAF logs for each fingerprint that goes above the
    # limit. Confirm that the fingerprint is used only by scrapers, not by
    # other clients (for example many IPs from corporate networks).
    {
      name          = "ratelimiting-no-alpn-pages"
      priority      = 14
      limit         = var.waf_no_alpn_page_rpm_limit
      action        = "count"
      label         = "no-alpn-page"
      aggregate_key = "JA4"
      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"
        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    }
  ]

  header_allow_rules = concat(
    nonsensitive(var.waf_mcp_secret_token != "") ? [
      {
        name        = "allow-mcp-server"
        priority    = 0
        header_name = "x-mcp-token"
      }
    ] : [],
    nonsensitive(var.WAF_E2E_SECRET_TOKEN != "") ? [
      {
        name        = "allow-e2e-tests"
        priority    = 8
        header_name = "x-waf-bypass"
      }
    ] : []
  )

  header_allow_values = merge(
    var.waf_mcp_secret_token != "" ? { "allow-mcp-server" = var.waf_mcp_secret_token } : {},
    var.WAF_E2E_SECRET_TOKEN != "" ? { "allow-e2e-tests" = var.WAF_E2E_SECRET_TOKEN } : {}
  )

  managed_rule_path_exceptions = [
    {
      name                 = "block-sqli-body-except-search"
      priority             = 55
      managed_rule_group   = "AWSManagedRulesSQLiRuleSet"
      managed_rule         = "SQLi_BODY"
      label                = "awswaf:managed:aws:sql-database:SQLi_Body"
      excluded_uri_path    = "/search"
      excluded_http_method = "POST"
    },
  ]

  bot_control_rule = {
    priority                = 70
    override_action         = "none"
    inspection_level        = "COMMON"
    enable_machine_learning = null
    excluded_uri_prefixes   = ["/uk/api/", "/xi/api/", "/api/", "/healthcheck"]
    captcha_override_rules  = []
  }

  # Page paths can have an optional /uk/ or /xi/ service prefix (see the
  # frontend service_path_prefix_handler route filter). Each regex covers the
  # unprefixed, UK and XI paths, so one counter per IP applies to all three.
  # The anchor at the start stops the rules matching API paths such as
  # /uk/api/commodities/. HMRC-2724.
  ip_rate_url_based_rules = [
    {
      name         = "rate-limit-commodity-pages"
      priority     = 15
      limit        = var.waf_page_rpm_limit
      action       = "block"
      regex_string = "^/(uk/|xi/)?commodities/"
    },
    {
      name         = "rate-limit-heading-pages"
      priority     = 16
      limit        = var.waf_page_rpm_limit
      action       = "block"
      regex_string = "^/(uk/|xi/)?headings/"
    },
    {
      name         = "rate-limit-chapter-pages"
      priority     = 17
      limit        = var.waf_page_rpm_limit
      action       = "block"
      regex_string = "^/(uk/|xi/)?chapters/"
    },
    {
      name         = "rate-limit-subheading-pages"
      priority     = 18
      limit        = var.waf_page_rpm_limit
      action       = "block"
      regex_string = "^/(uk/|xi/)?subheadings/"
    },
    {
      name         = "rate-limit-search"
      priority     = 19
      limit        = var.waf_search_rpm_limit
      action       = "block"
      regex_string = "^/(uk/|xi/)?search$"
    },
  ]

  uri_path_match_rules = [
    {
      name                  = "allow-healthcheck"
      priority              = 9
      action                = "allow"
      search_string         = "/healthcheck"
      positional_constraint = "EXACTLY"
    },
    {
      name                  = "allow-mycommodities-path"
      priority              = 10
      action                = "allow"
      search_string         = "/subscriptions/mycommodities"
      positional_constraint = "CONTAINS"
    }
  ]

}

resource "aws_cloudwatch_log_group" "waf_logs" {
  provider          = aws.us_east_1
  name              = "aws-waf-logs-tariff-${var.environment}"
  retention_in_days = 60
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
  provider = aws.us_east_1

  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = module.waf.web_acl_id

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}

data "aws_iam_policy_document" "waf_log_group_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.waf_logs.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "waf_logs" {
  policy_document = data.aws_iam_policy_document.waf_log_group_policy.json
  policy_name     = "tariff-waf-logs-policy-${var.environment}"
}
