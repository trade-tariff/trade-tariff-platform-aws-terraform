<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_base_path_mapping.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_integration.proxy_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.root_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.uk_exceptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.uk_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.xi_exceptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.xi_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.proxy_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.root_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.root_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.uk_exceptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.uk_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.xi_exceptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.xi_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.proxy_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.root_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_method_settings.uk_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_method_settings.xi_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.uk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.uk_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.uk_exceptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.uk_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.xi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.xi_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.xi_exceptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.xi_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_apigatewayv2_vpc_link.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_vpc_link) | resource |
| [aws_route53_record.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_secret_header"></a> [alb\_secret\_header](#input\_alb\_secret\_header) | Secret header name and value to be sent to the ALB on every request. | `list(string)` | n/a | yes |
| <a name="input_cache_cluster_enabled"></a> [cache\_cluster\_enabled](#input\_cache\_cluster\_enabled) | Enable or disable the API Gateway cache cluster. | `bool` | `false` | no |
| <a name="input_cache_cluster_size"></a> [cache\_cluster\_size](#input\_cache\_cluster\_size) | The size of the cache cluster for the API Gateway. | `string` | `"0.5"` | no |
| <a name="input_cache_key_params"></a> [cache\_key\_params](#input\_cache\_key\_params) | List of query string parameters to include in the cache key. | `list(string)` | <pre>[<br/>  "as_of",<br/>  "country_code",<br/>  "heading_code",<br/>  "include",<br/>  "limit",<br/>  "page",<br/>  "per_page",<br/>  "filter.exclude_none",<br/>  "filter.from_date",<br/>  "filter.geographical_area_id",<br/>  "filter.has_article",<br/>  "filter.meursing_additional_code_id",<br/>  "filter.simplified_procedural_code",<br/>  "filter.to_date",<br/>  "filter.type"<br/>]</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name for the application. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment (e.g., dev, staging, prod). | `string` | n/a | yes |
| <a name="input_lb_arn"></a> [lb\_arn](#input\_lb\_arn) | ALB ARN for the V2 VPC Link integrations. | `string` | n/a | yes |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | The log level for the API Gateway. | `string` | `"INFO"` | no |
| <a name="input_long_cache_ttl"></a> [long\_cache\_ttl](#input\_long\_cache\_ttl) | The TTL for long cache duration in seconds. | `number` | `3600` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for the V2 VPC Link. | `list(string)` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to give access to the V2 VPC Link. | `list(string)` | n/a | yes |
| <a name="input_uk_uncached_paths"></a> [uk\_uncached\_paths](#input\_uk\_uncached\_paths) | List of API paths that should not be cached on the UK service. | `set(string)` | <pre>[<br/>  "exchange_rates",<br/>  "healthcheck",<br/>  "live_issues",<br/>  "news",<br/>  "search_references"<br/>]</pre> | no |
| <a name="input_validated_certificate_arn"></a> [validated\_certificate\_arn](#input\_validated\_certificate\_arn) | The ARN of the validated SSL certificate. | `string` | n/a | yes |
| <a name="input_xi_uncached_paths"></a> [xi\_uncached\_paths](#input\_xi\_uncached\_paths) | List of API paths that should not be cached on the XI service. | `set(string)` | <pre>[<br/>  "green_lanes",<br/>  "healthcheck",<br/>  "search_references"<br/>]</pre> | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The Route 53 Hosted Zone ID for the domain. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | ID of the API Gateway REST API. |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | Name of the deployed stage. |
<!-- END_TF_DOCS -->
