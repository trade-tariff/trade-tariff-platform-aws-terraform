# common

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.13.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../../common/acm/ | n/a |
| <a name="module_acm_origin"></a> [acm\_origin](#module\_acm\_origin) | ../../common/acm | n/a |
| <a name="module_admin_bearer_token"></a> [admin\_bearer\_token](#module\_admin\_bearer\_token) | ../../common/secret/ | n/a |
| <a name="module_admin_oauth_id"></a> [admin\_oauth\_id](#module\_admin\_oauth\_id) | ../../common/secret/ | n/a |
| <a name="module_admin_oauth_secret"></a> [admin\_oauth\_secret](#module\_admin\_oauth\_secret) | ../../common/secret/ | n/a |
| <a name="module_admin_secret_key_base"></a> [admin\_secret\_key\_base](#module\_admin\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_admin_sentry_dsn"></a> [admin\_sentry\_dsn](#module\_admin\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_alb"></a> [alb](#module\_alb) | ../../common/application-load-balancer/ | n/a |
| <a name="module_alb-security-group"></a> [alb-security-group](#module\_alb-security-group) | ../../common/security-group/ | n/a |
| <a name="module_api_cdn"></a> [api\_cdn](#module\_api\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.2.1 |
| <a name="module_backend_differences_to_emails"></a> [backend\_differences\_to\_emails](#module\_backend\_differences\_to\_emails) | ../../common/secret/ | n/a |
| <a name="module_backend_oauth_id"></a> [backend\_oauth\_id](#module\_backend\_oauth\_id) | ../../common/secret/ | n/a |
| <a name="module_backend_oauth_secret"></a> [backend\_oauth\_secret](#module\_backend\_oauth\_secret) | ../../common/secret/ | n/a |
| <a name="module_backend_secret_key_base"></a> [backend\_secret\_key\_base](#module\_backend\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_backend_sentry_dsn"></a> [backend\_sentry\_dsn](#module\_backend\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_backend_sync_email"></a> [backend\_sync\_email](#module\_backend\_sync\_email) | ../../common/secret/ | n/a |
| <a name="module_backend_uk_sync_host"></a> [backend\_uk\_sync\_host](#module\_backend\_uk\_sync\_host) | ../../common/secret/ | n/a |
| <a name="module_backend_uk_sync_password"></a> [backend\_uk\_sync\_password](#module\_backend\_uk\_sync\_password) | ../../common/secret/ | n/a |
| <a name="module_backend_uk_sync_username"></a> [backend\_uk\_sync\_username](#module\_backend\_uk\_sync\_username) | ../../common/secret/ | n/a |
| <a name="module_backend_xi_sync_host"></a> [backend\_xi\_sync\_host](#module\_backend\_xi\_sync\_host) | ../../common/secret/ | n/a |
| <a name="module_backend_xi_sync_password"></a> [backend\_xi\_sync\_password](#module\_backend\_xi\_sync\_password) | ../../common/secret/ | n/a |
| <a name="module_backend_xi_sync_username"></a> [backend\_xi\_sync\_username](#module\_backend\_xi\_sync\_username) | ../../common/secret/ | n/a |
| <a name="module_cdn"></a> [cdn](#module\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.2.1 |
| <a name="module_cloudwatch"></a> [cloudwatch](#module\_cloudwatch) | ../../common/cloudwatch/ | n/a |
| <a name="module_cloudwatch-logs-exporter"></a> [cloudwatch-logs-exporter](#module\_cloudwatch-logs-exporter) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudwatch_log_exporter | aws/cloudwatch_log_exporter-v1.0.0 |
| <a name="module_duty_calculator_secret_key_base"></a> [duty\_calculator\_secret\_key\_base](#module\_duty\_calculator\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_frontend_secret_key_base"></a> [frontend\_secret\_key\_base](#module\_frontend\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_logs"></a> [logs](#module\_logs) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_mysql"></a> [mysql](#module\_mysql) | ../../common/rds | n/a |
| <a name="module_opensearch"></a> [opensearch](#module\_opensearch) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/opensearch | aws/opensearch-v1.1.0 |
| <a name="module_opensearch_packages_bucket"></a> [opensearch\_packages\_bucket](#module\_opensearch\_packages\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../common/rds | n/a |
| <a name="module_postgres_admin"></a> [postgres\_admin](#module\_postgres\_admin) | ../../common/rds | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ../../common/elasticache-redis/ | n/a |
| <a name="module_search_configuration_bucket"></a> [search\_configuration\_bucket](#module\_search\_configuration\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_signon_derivation_key"></a> [signon\_derivation\_key](#module\_signon\_derivation\_key) | ../../common/secret/ | n/a |
| <a name="module_signon_derivation_salt"></a> [signon\_derivation\_salt](#module\_signon\_derivation\_salt) | ../../common/secret/ | n/a |
| <a name="module_signon_devise_pepper"></a> [signon\_devise\_pepper](#module\_signon\_devise\_pepper) | ../../common/secret/ | n/a |
| <a name="module_signon_devise_secret_key"></a> [signon\_devise\_secret\_key](#module\_signon\_devise\_secret\_key) | ../../common/secret/ | n/a |
| <a name="module_signon_govuk_notify_api_key"></a> [signon\_govuk\_notify\_api\_key](#module\_signon\_govuk\_notify\_api\_key) | ../../common/secret/ | n/a |
| <a name="module_signon_secret_key_base"></a> [signon\_secret\_key\_base](#module\_signon\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_waf"></a> [waf](#module\_waf) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/waf | aws/waf-v1.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.cache_all_qsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_origin_request_policy.forward_all_qsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudwatch_log_group.redis_engine_lg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.redis_slow_lg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_policy.ci_appendix5a_peristence_readwrite_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_lambda_deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.breakglass_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.appendix5a_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.serverless_lambda_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.appendix5a_ci_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.serverless_lambda_ci_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_kms_alias.logs_bucket_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.opensearch_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.s3_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secretsmanager_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.logs_bucket_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.opensearch_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.secretsmanager_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.logs_bucket_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_route53_record.origin_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_wildcard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.redis_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.redis_reader_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.redis_connection_string_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.redis_reader_connection_string_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_parameter.ecr_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudfront_cache_policy.caching_disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_iam_policy_document.breakglass_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.opensearch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | n/a | `map(string)` | <pre>{<br>  "development": "844815912454",<br>  "production": "382373577178",<br>  "staging": "451934005581"<br>}</pre> | no |
| <a name="input_admin_bearer_token"></a> [admin\_bearer\_token](#input\_admin\_bearer\_token) | Value of BEARER\_TOKEN for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_oauth_id"></a> [admin\_oauth\_id](#input\_admin\_oauth\_id) | Value of TARIFF\_ADMIN\_OAUTH\_ID for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_oauth_secret"></a> [admin\_oauth\_secret](#input\_admin\_oauth\_secret) | Value of TARIFF\_ADMIN\_OAUTH\_SECRET for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_secret_key_base"></a> [admin\_secret\_key\_base](#input\_admin\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_sentry_dsn"></a> [admin\_sentry\_dsn](#input\_admin\_sentry\_dsn) | Value of Sentry DSN for the admin tool. | `string` | n/a | yes |
| <a name="input_backend_secret_key_base"></a> [backend\_secret\_key\_base](#input\_backend\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the backend. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the service. | `string` | `"ott-staging.co.uk"` | no |
| <a name="input_duty_calculator_secret_key_base"></a> [duty\_calculator\_secret\_key\_base](#input\_duty\_calculator\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the duty calculator. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"staging"` | no |
| <a name="input_frontend_secret_key_base"></a> [frontend\_secret\_key\_base](#input\_frontend\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the frontend. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_signon_derivation_key"></a> [signon\_derivation\_key](#input\_signon\_derivation\_key) | Value of ACTIVE\_RECORD\_ENCRYPTION\_PRIMARY\_KEY for the signon app. | `string` | n/a | yes |
| <a name="input_signon_derivation_salt"></a> [signon\_derivation\_salt](#input\_signon\_derivation\_salt) | Value of ACTIVE\_RECORD\_ENCRYPTION\_KEY\_DERIVATION\_SALT for the signon app. | `string` | n/a | yes |
| <a name="input_signon_devise_pepper"></a> [signon\_devise\_pepper](#input\_signon\_devise\_pepper) | Value of DEVISE\_PEPPER for the signon app. | `string` | n/a | yes |
| <a name="input_signon_devise_secret_key"></a> [signon\_devise\_secret\_key](#input\_signon\_devise\_secret\_key) | Value of DEVISE\_SECRET\_KEY for the signon app. | `string` | n/a | yes |
| <a name="input_signon_govuk_notify_api_key"></a> [signon\_govuk\_notify\_api\_key](#input\_signon\_govuk\_notify\_api\_key) | Value of GOVUK\_NOTIFY\_API\_KEY for the signon app. | `string` | n/a | yes |
| <a name="input_signon_secret_key_base"></a> [signon\_secret\_key\_base](#input\_signon\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the signon app. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | <pre>{<br>  "Billing": "TRN.HMR11896",<br>  "Environment": "staging",<br>  "Project": "trade-tariff",<br>  "Terraform": true<br>}</pre> | no |
| <a name="input_tariff_backend_differences_to_emails"></a> [tariff\_backend\_differences\_to\_emails](#input\_tariff\_backend\_differences\_to\_emails) | Differences report TO email addresses. | `string` | n/a | yes |
| <a name="input_tariff_backend_oauth_id"></a> [tariff\_backend\_oauth\_id](#input\_tariff\_backend\_oauth\_id) | Value of Tariff Backend OAuth ID. | `string` | n/a | yes |
| <a name="input_tariff_backend_oauth_secret"></a> [tariff\_backend\_oauth\_secret](#input\_tariff\_backend\_oauth\_secret) | Value of Tariff Backend OAuth secret. | `string` | n/a | yes |
| <a name="input_tariff_backend_sentry_dsn"></a> [tariff\_backend\_sentry\_dsn](#input\_tariff\_backend\_sentry\_dsn) | Value of Backend Sentry DSN. | `string` | n/a | yes |
| <a name="input_tariff_backend_sync_email"></a> [tariff\_backend\_sync\_email](#input\_tariff\_backend\_sync\_email) | Value of Tariff Sync email. | `string` | n/a | yes |
| <a name="input_tariff_backend_uk_sync_host"></a> [tariff\_backend\_uk\_sync\_host](#input\_tariff\_backend\_uk\_sync\_host) | Value of Tariff Sync host. | `string` | n/a | yes |
| <a name="input_tariff_backend_uk_sync_password"></a> [tariff\_backend\_uk\_sync\_password](#input\_tariff\_backend\_uk\_sync\_password) | Value of Tariff Sync password. | `string` | n/a | yes |
| <a name="input_tariff_backend_uk_sync_username"></a> [tariff\_backend\_uk\_sync\_username](#input\_tariff\_backend\_uk\_sync\_username) | Value of Tariff Sync username. | `string` | n/a | yes |
| <a name="input_tariff_backend_xi_sync_host"></a> [tariff\_backend\_xi\_sync\_host](#input\_tariff\_backend\_xi\_sync\_host) | Value of Tariff Sync host. | `string` | n/a | yes |
| <a name="input_tariff_backend_xi_sync_password"></a> [tariff\_backend\_xi\_sync\_password](#input\_tariff\_backend\_xi\_sync\_password) | Value of Tariff Sync password. | `string` | n/a | yes |
| <a name="input_tariff_backend_xi_sync_username"></a> [tariff\_backend\_xi\_sync\_username](#input\_tariff\_backend\_xi\_sync\_username) | Value of Tariff Sync username. | `string` | n/a | yes |
| <a name="input_waf_rpm_limit"></a> [waf\_rpm\_limit](#input\_waf\_rpm\_limit) | Request per minute limit for the WAF. | `number` | `500` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
