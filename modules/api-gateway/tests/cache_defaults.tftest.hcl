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
