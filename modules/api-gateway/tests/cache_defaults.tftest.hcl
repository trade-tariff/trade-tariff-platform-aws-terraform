provider "aws" {
  region                      = "eu-west-2"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "cache_defaults_cover_backend_query_params" {
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
    condition = alltrue([
      for param in [
        "as_of",
        "country_code",
        "heading_code",
        "include",
        "fields",
        "fields.additional_code",
        "fields.additional_code_type",
        "fields.category_assessment",
        "fields.certificate",
        "fields.certificate_type",
        "fields.change",
        "fields.chapter",
        "fields.chemical",
        "fields.chemical_substance",
        "fields.commodity",
        "fields.definition",
        "fields.description_intercept",
        "fields.duty_expression",
        "fields.exact_search",
        "fields.exchange_rate",
        "fields.exchange_rate_collection",
        "fields.exchange_rate_file",
        "fields.exchange_rate_period",
        "fields.exchange_rate_period_list",
        "fields.exchange_rate_year",
        "fields.footnote",
        "fields.footnote_type",
        "fields.fuzzy_search",
        "fields.geographical_area",
        "fields.goods_nomenclature",
        "fields.green_lanes_faq_feedback",
        "fields.guide",
        "fields.heading",
        "fields.import_trade_summary",
        "fields.legal_act",
        "fields.live_issue",
        "fields.measure",
        "fields.measure_action",
        "fields.measure_component",
        "fields.measure_condition",
        "fields.measure_condition_code",
        "fields.measure_condition_component",
        "fields.measure_condition_permutation",
        "fields.measure_condition_permutation_group",
        "fields.measure_type",
        "fields.measurement_unit",
        "fields.measurement_unit_qualifier",
        "fields.monetary_exchange_rate",
        "fields.national_measurement_unit",
        "fields.news_collection",
        "fields.news_item",
        "fields.news_year",
        "fields.null_search",
        "fields.order_number",
        "fields.preference_code",
        "fields.quota_balance_event",
        "fields.quota_closed_and_transferred_event",
        "fields.quota_definition",
        "fields.quota_order_number",
        "fields.quota_order_number_origin",
        "fields.quota_order_number_origin_exclusion",
        "fields.rules_of_origin_article",
        "fields.rules_of_origin_link",
        "fields.rules_of_origin_origin_reference_document",
        "fields.rules_of_origin_proof",
        "fields.rules_of_origin_rule",
        "fields.rules_of_origin_rule_set",
        "fields.rules_of_origin_scheme",
        "fields.rules_of_origin_v2_rule",
        "fields.search_reference",
        "fields.search_suggestion",
        "fields.section",
        "fields.simplified_procedural_code_measure",
        "fields.subheading",
        "fields.suspension_legal_act",
        "fields.tariff_update",
        "fields.validity_period",
        "limit",
        "page",
        "per_page",
        "type",
        "code",
        "description",
        "order_number",
        "year",
        "month",
        "day",
        "name",
        "cas",
        "source",
        "excluded",
        "critical",
        "geographical_area_id",
        "goods_nomenclature_item_id",
        "status",
        "q",
        "query.letter",
        "filter.cas_rn",
        "filter.cus",
        "filter.exclude_none",
        "filter.from_date",
        "filter.geographical_area_id",
        "filter.goods_nomenclature_item_id",
        "filter.goods_nomenclature_sid",
        "filter.has_article",
        "filter.meursing_additional_code_id",
        "filter.simplified_procedural_code",
        "filter.status",
        "filter.to_date",
        "filter.type",
      ] : contains(var.cache_key_params, param)
    ])

    error_message = "cache_key_params must include every backend-supported query parameter that can change cached API responses."
  }

  assert {
    condition = alltrue([
      for path in [
        "chemical_substances",
        "description_intercepts",
        "search",
        "search_suggestions",
      ] : contains(var.uk_uncached_paths, path)
    ])

    error_message = "UK uncached paths must carve out top-level search/filter endpoints where API Gateway response caching is not aligned with backend behavior."
  }

  assert {
    condition = alltrue([
      for path in [
        "chemical_substances",
        "description_intercepts",
        "search",
        "search_suggestions",
      ] : contains(var.xi_uncached_paths, path)
    ])

    error_message = "XI uncached paths must carve out top-level search/filter endpoints where API Gateway response caching is not aligned with backend behavior."
  }
}
