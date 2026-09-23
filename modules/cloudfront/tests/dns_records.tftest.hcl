mock_provider "aws" {}

variables {
  aliases         = ["example.trade-tariff.service.gov.uk", "admin.example.trade-tariff.service.gov.uk"]
  route53_zone_id = "Z0000000000000000000A"

  origin = {
    alb = {
      domain_name = "alb.example.com"
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "alb"
      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    },
  ]
}

run "creates_no_dns_records_by_default" {
  command = plan

  assert {
    condition     = length(aws_route53_record.alias_record) == 0
    error_message = "No A records must be created when create_alias is false."
  }

  assert {
    condition     = length(aws_route53_record.cname_record) == 0
    error_message = "No CNAME records must be created when create_cname is false."
  }
}

# The distribution domain_name and hosted_zone_id are computed, so the alias
# target and CNAME value are unknown at plan. These runs assert on the record
# keys, names, types and zone only.
run "creates_one_a_record_per_alias_when_create_alias_is_true" {
  command = plan

  variables {
    create_alias = true
  }

  assert {
    condition     = toset(keys(aws_route53_record.alias_record)) == toset(["example.trade-tariff.service.gov.uk", "admin.example.trade-tariff.service.gov.uk"])
    error_message = "There must be one A record for each alias."
  }

  assert {
    condition     = alltrue([for record in aws_route53_record.alias_record : record.type == "A" && record.zone_id == "Z0000000000000000000A"])
    error_message = "Every alias record must be an A record in the zone that the caller gives."
  }

  assert {
    condition     = aws_route53_record.alias_record["admin.example.trade-tariff.service.gov.uk"].name == "admin.example.trade-tariff.service.gov.uk"
    error_message = "Each A record name must be its alias."
  }

  assert {
    condition     = alltrue([for record in aws_route53_record.alias_record : one(record.alias).evaluate_target_health == true])
    error_message = "Every A record must evaluate target health."
  }

  assert {
    condition     = length(aws_route53_record.cname_record) == 0
    error_message = "No CNAME records must be created when only create_alias is true."
  }
}

run "creates_one_cname_record_per_alias_when_create_cname_is_true" {
  command = plan

  variables {
    create_cname    = true
    health_check_id = "00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = toset(keys(aws_route53_record.cname_record)) == toset(["example.trade-tariff.service.gov.uk", "admin.example.trade-tariff.service.gov.uk"])
    error_message = "There must be one CNAME record for each alias."
  }

  assert {
    condition     = alltrue([for record in aws_route53_record.cname_record : record.type == "CNAME" && record.ttl == 60])
    error_message = "Every CNAME record must have type CNAME and a TTL of 60 seconds."
  }

  assert {
    condition     = alltrue([for record in aws_route53_record.cname_record : record.health_check_id == "00000000-0000-0000-0000-000000000000"])
    error_message = "Every CNAME record must use the health check that the caller gives."
  }

  assert {
    condition     = length(aws_route53_record.alias_record) == 0
    error_message = "No A records must be created when only create_cname is true."
  }
}
