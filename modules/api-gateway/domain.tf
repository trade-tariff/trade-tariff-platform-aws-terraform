resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.${var.domain_name}"
  regional_certificate_arn = var.validated_certificate_arn
  security_policy          = "SecurityPolicy_TLS13_1_2_2021_06"
  endpoint_access_mode     = "BASIC" # TODO After you validate your traffic and access logs, set the endpoint access mode to STRICT

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
    evaluate_target_health = true
  }
}
