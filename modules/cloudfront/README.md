<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.alias_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cname_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Extra CNAMEs (alternate domain names), if any, for this distribution. | `list(string)` | `null` | no |
| <a name="input_cache_behaviors"></a> [cache\_behaviors](#input\_cache\_behaviors) | List of cache behaviors in order of precedence (most specific first). Leave path\_pattern empty when configuring the default behavior | <pre>list(object({<br/>    name                       = string<br/>    path_pattern               = optional(string)<br/>    target_origin_id           = string<br/>    viewer_protocol_policy     = optional(string, "redirect-to-https")<br/>    cache_policy_id            = string<br/>    origin_request_policy_id   = string<br/>    response_headers_policy_id = string<br/><br/>    # Optional fields with defaults<br/>    allowed_methods           = optional(list(string), ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"])<br/>    cached_methods            = optional(list(string), ["GET", "HEAD"])<br/>    compress                  = optional(bool, true)<br/>    field_level_encryption_id = optional(string)<br/>    smooth_streaming          = optional(bool)<br/>    trusted_signers           = optional(list(string))<br/><br/>    # Legacy TTL settings (usually not needed with cache policies)<br/>    min_ttl     = optional(number, 0)<br/>    default_ttl = optional(number, 0)<br/>    max_ttl     = optional(number, 0)<br/><br/>    # Function associations<br/>    function_association = optional(map(object({<br/>      function_arn = string<br/>    })), {})<br/><br/>    # Lambda function associations<br/>    lambda_function_association = optional(map(object({<br/>      lambda_arn   = string<br/>      include_body = optional(bool)<br/>    })), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Any comments you want to include about the distribution. | `string` | `null` | no |
| <a name="input_create_alias"></a> [create\_alias](#input\_create\_alias) | Whether to create a Route 53 A record. | `bool` | `false` | no |
| <a name="input_create_cname"></a> [create\_cname](#input\_create\_cname) | Whether to create a Route 53 CNAME record. | `bool` | `false` | no |
| <a name="input_create_distribution"></a> [create\_distribution](#input\_create\_distribution) | Controls if CloudFront distribution should be created | `bool` | `true` | no |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | One or more custom error response elements | `any` | `{}` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content. | `bool` | `true` | no |
| <a name="input_geo_restriction"></a> [geo\_restriction](#input\_geo\_restriction) | The restriction configuration for this distribution (geo\_restrictions) | `any` | `{}` | no |
| <a name="input_health_check_id"></a> [health\_check\_id](#input\_health\_check\_id) | The health check the record should be associated with. | `string` | `null` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2. The default is http2. | `string` | `"http2"` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | Whether the IPv6 is enabled for the distribution. | `bool` | `null` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | The logging configuration that controls how logs are written to your distribution (maximum one). | `any` | `{}` | no |
| <a name="input_origin"></a> [origin](#input\_origin) | One or more origins for this distribution (multiples allowed). | `any` | `null` | no |
| <a name="input_origin_group"></a> [origin\_group](#input\_origin\_group) | One or more origin\_group for this distribution (multiples allowed). | `any` | `{}` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | The price class for this distribution. One of PriceClass\_All, PriceClass\_200, PriceClass\_100 | `string` | `null` | no |
| <a name="input_retain_on_delete"></a> [retain\_on\_delete](#input\_retain\_on\_delete) | Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards. | `bool` | `false` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | The ID of the Route53 zone where to create the Cloudfront alias CNAME records | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_viewer_certificate"></a> [viewer\_certificate](#input\_viewer\_certificate) | The SSL configuration for this distribution | `any` | <pre>{<br/>  "cloudfront_default_certificate": true,<br/>  "minimum_protocol_version": "TLSv1"<br/>}</pre> | no |
| <a name="input_wait_for_deployment"></a> [wait\_for\_deployment](#input\_wait\_for\_deployment) | If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process. | `bool` | `true` | no |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_cloudfront_distribution_arn"></a> [aws\_cloudfront\_distribution\_arn](#output\_aws\_cloudfront\_distribution\_arn) | n/a |
| <a name="output_aws_cloudfront_distribution_domain_name"></a> [aws\_cloudfront\_distribution\_domain\_name](#output\_aws\_cloudfront\_distribution\_domain\_name) | n/a |
| <a name="output_aws_cloudfront_distribution_hosted_zone_id"></a> [aws\_cloudfront\_distribution\_hosted\_zone\_id](#output\_aws\_cloudfront\_distribution\_hosted\_zone\_id) | n/a |
| <a name="output_aws_cloudfront_distribution_id"></a> [aws\_cloudfront\_distribution\_id](#output\_aws\_cloudfront\_distribution\_id) | n/a |
<!-- END_TF_DOCS -->
