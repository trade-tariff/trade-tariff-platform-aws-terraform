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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.25.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../../common/acm/ | n/a |
| <a name="module_acm_london"></a> [acm\_london](#module\_acm\_london) | ../../common/acm/ | n/a |
| <a name="module_acm_origin"></a> [acm\_origin](#module\_acm\_origin) | ../../common/acm | n/a |
| <a name="module_admin_bearer_token"></a> [admin\_bearer\_token](#module\_admin\_bearer\_token) | ../../common/secret/ | n/a |
| <a name="module_admin_oauth_id"></a> [admin\_oauth\_id](#module\_admin\_oauth\_id) | ../../common/secret/ | n/a |
| <a name="module_admin_oauth_secret"></a> [admin\_oauth\_secret](#module\_admin\_oauth\_secret) | ../../common/secret/ | n/a |
| <a name="module_admin_secret_key_base"></a> [admin\_secret\_key\_base](#module\_admin\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_admin_sentry_dsn"></a> [admin\_sentry\_dsn](#module\_admin\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_alb"></a> [alb](#module\_alb) | ../../common/application-load-balancer/ | n/a |
| <a name="module_alb-security-group"></a> [alb-security-group](#module\_alb-security-group) | ../../common/security-group/ | n/a |
| <a name="module_api_cdn"></a> [api\_cdn](#module\_api\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.4.2 |
| <a name="module_backend_differences_to_emails"></a> [backend\_differences\_to\_emails](#module\_backend\_differences\_to\_emails) | ../../common/secret/ | n/a |
| <a name="module_backend_oauth_id"></a> [backend\_oauth\_id](#module\_backend\_oauth\_id) | ../../common/secret/ | n/a |
| <a name="module_backend_oauth_secret"></a> [backend\_oauth\_secret](#module\_backend\_oauth\_secret) | ../../common/secret/ | n/a |
| <a name="module_backend_secret_key_base"></a> [backend\_secret\_key\_base](#module\_backend\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_backend_sentry_dsn"></a> [backend\_sentry\_dsn](#module\_backend\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_backend_sync_email"></a> [backend\_sync\_email](#module\_backend\_sync\_email) | ../../common/secret/ | n/a |
| <a name="module_backend_uk_sync_host"></a> [backend\_uk\_sync\_host](#module\_backend\_uk\_sync\_host) | ../../common/secret/ | n/a |
| <a name="module_backend_uk_sync_password"></a> [backend\_uk\_sync\_password](#module\_backend\_uk\_sync\_password) | ../../common/secret/ | n/a |
| <a name="module_backend_uk_sync_username"></a> [backend\_uk\_sync\_username](#module\_backend\_uk\_sync\_username) | ../../common/secret/ | n/a |
| <a name="module_backend_xe_api_password"></a> [backend\_xe\_api\_password](#module\_backend\_xe\_api\_password) | ../../common/secret/ | n/a |
| <a name="module_backend_xe_api_username"></a> [backend\_xe\_api\_username](#module\_backend\_xe\_api\_username) | ../../common/secret/ | n/a |
| <a name="module_backend_xi_sync_host"></a> [backend\_xi\_sync\_host](#module\_backend\_xi\_sync\_host) | ../../common/secret/ | n/a |
| <a name="module_backend_xi_sync_password"></a> [backend\_xi\_sync\_password](#module\_backend\_xi\_sync\_password) | ../../common/secret/ | n/a |
| <a name="module_backend_xi_sync_username"></a> [backend\_xi\_sync\_username](#module\_backend\_xi\_sync\_username) | ../../common/secret/ | n/a |
| <a name="module_backups_cdn"></a> [backups\_cdn](#module\_backups\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.4.2 |
| <a name="module_cdn"></a> [cdn](#module\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.4.2 |
| <a name="module_cloudwatch"></a> [cloudwatch](#module\_cloudwatch) | ../../common/cloudwatch/ | n/a |
| <a name="module_cloudwatch-logs-exporter"></a> [cloudwatch-logs-exporter](#module\_cloudwatch-logs-exporter) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudwatch_log_exporter | aws/cloudwatch_log_exporter-v1.0.0 |
| <a name="module_duty_calculator_secret_key_base"></a> [duty\_calculator\_secret\_key\_base](#module\_duty\_calculator\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_duty_calculator_sentry_dsn"></a> [duty\_calculator\_sentry\_dsn](#module\_duty\_calculator\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../common/ecr/ | n/a |
| <a name="module_frontend_secret_key_base"></a> [frontend\_secret\_key\_base](#module\_frontend\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_frontend_sentry_dsn"></a> [frontend\_sentry\_dsn](#module\_frontend\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_logs"></a> [logs](#module\_logs) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_notify_slack"></a> [notify\_slack](#module\_notify\_slack) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/aws-notify-slack | aws/aws-notify-slack-v1.0.0 |
| <a name="module_opensearch"></a> [opensearch](#module\_opensearch) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/opensearch | aws/opensearch-v1.2.0 |
| <a name="module_opensearch_packages_bucket"></a> [opensearch\_packages\_bucket](#module\_opensearch\_packages\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../common/rds | n/a |
| <a name="module_postgres_admin"></a> [postgres\_admin](#module\_postgres\_admin) | ../../common/rds | n/a |
| <a name="module_read_only_postgres_connection_string"></a> [read\_only\_postgres\_connection\_string](#module\_read\_only\_postgres\_connection\_string) | ../../common/secret/ | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ../../common/elasticache-redis/ | n/a |
| <a name="module_reporting_cdn"></a> [reporting\_cdn](#module\_reporting\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.4.2 |
| <a name="module_search_configuration_bucket"></a> [search\_configuration\_bucket](#module\_search\_configuration\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_search_query_parser_sentry_dsn"></a> [search\_query\_parser\_sentry\_dsn](#module\_search\_query\_parser\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_ses"></a> [ses](#module\_ses) | ../../common/ses | n/a |
| <a name="module_slack_web_hook_url"></a> [slack\_web\_hook\_url](#module\_slack\_web\_hook\_url) | ../../common/secret/ | n/a |
| <a name="module_waf"></a> [waf](#module\_waf) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/waf | aws/waf-v1.2.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.cache_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_cache_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_function.basic_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.forward_all_qsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_origin_request_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_response_headers_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cloudwatch_log_group.redis_engine_lg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.redis_slow_lg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.dns_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.high_4xx_codes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.high_5xx_codes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.high_connections_refused](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.long_response_times](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecr_repository_policy.ecr_allow_staging_and_development](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_policy.ci_appendix5a_peristence_readwrite_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_cds_downloader_file_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_etf_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_lambda_deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_reporting_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.release_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.breakglass_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.appendix5a_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.cds_downloader_file_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.etf_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.releases_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.reporting_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.serverless_lambda_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.appendix5a_ci_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.cds_downloader_file_ci_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.etf_ci_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.release_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.reporting_ci_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
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
| [aws_kms_key_policy.s3_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_route53_health_check.dns_health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_record.dev_name_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.google_site_verification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_wildcard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.sandbox_name_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.staging_name_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.reporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
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
| [aws_iam_policy_document.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.breakglass_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.opensearch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.reporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret_version.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.development](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.staging](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

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
| <a name="input_backups_basic_auth"></a> [backups\_basic\_auth](#input\_backups\_basic\_auth) | base64 encoded credentials for backups basic auth. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the service. | `string` | `"trade-tariff.service.gov.uk"` | no |
| <a name="input_duty_calculator_secret_key_base"></a> [duty\_calculator\_secret\_key\_base](#input\_duty\_calculator\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the duty calculator. | `string` | n/a | yes |
| <a name="input_duty_calculator_sentry_dsn"></a> [duty\_calculator\_sentry\_dsn](#input\_duty\_calculator\_sentry\_dsn) | Value of SENTRY\_DSN for the duty calculator. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"production"` | no |
| <a name="input_frontend_secret_key_base"></a> [frontend\_secret\_key\_base](#input\_frontend\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the frontend. | `string` | n/a | yes |
| <a name="input_frontend_sentry_dsn"></a> [frontend\_sentry\_dsn](#input\_frontend\_sentry\_dsn) | Value of SENTRY\_DSN for the frontend. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_search_query_parser_sentry_dsn"></a> [search\_query\_parser\_sentry\_dsn](#input\_search\_query\_parser\_sentry\_dsn) | Value of SENTRY\_DSN for the search query parser. | `string` | n/a | yes |
| <a name="input_slack_web_hook_url"></a> [slack\_web\_hook\_url](#input\_slack\_web\_hook\_url) | Value of SLACK\_WEB\_HOOK\_URL for the backend. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | <pre>{<br>  "Billing": "TRN.HMR11896",<br>  "Environment": "production",<br>  "Project": "trade-tariff",<br>  "Terraform": true<br>}</pre> | no |
| <a name="input_tariff_backend_differences_to_emails"></a> [tariff\_backend\_differences\_to\_emails](#input\_tariff\_backend\_differences\_to\_emails) | Differences report TO email addresses. | `string` | n/a | yes |
| <a name="input_tariff_backend_oauth_id"></a> [tariff\_backend\_oauth\_id](#input\_tariff\_backend\_oauth\_id) | Value of Tariff Backend OAuth ID. | `string` | n/a | yes |
| <a name="input_tariff_backend_oauth_secret"></a> [tariff\_backend\_oauth\_secret](#input\_tariff\_backend\_oauth\_secret) | Value of Tariff Backend OAuth secret. | `string` | n/a | yes |
| <a name="input_tariff_backend_sentry_dsn"></a> [tariff\_backend\_sentry\_dsn](#input\_tariff\_backend\_sentry\_dsn) | Value of Backend Sentry DSN. | `string` | n/a | yes |
| <a name="input_tariff_backend_sync_email"></a> [tariff\_backend\_sync\_email](#input\_tariff\_backend\_sync\_email) | Value of Tariff Sync email. | `string` | n/a | yes |
| <a name="input_tariff_backend_uk_sync_host"></a> [tariff\_backend\_uk\_sync\_host](#input\_tariff\_backend\_uk\_sync\_host) | Value of Tariff Sync host. | `string` | n/a | yes |
| <a name="input_tariff_backend_uk_sync_password"></a> [tariff\_backend\_uk\_sync\_password](#input\_tariff\_backend\_uk\_sync\_password) | Value of Tariff Sync password. | `string` | n/a | yes |
| <a name="input_tariff_backend_uk_sync_username"></a> [tariff\_backend\_uk\_sync\_username](#input\_tariff\_backend\_uk\_sync\_username) | Value of Tariff Sync username. | `string` | n/a | yes |
| <a name="input_tariff_backend_xe_api_password"></a> [tariff\_backend\_xe\_api\_password](#input\_tariff\_backend\_xe\_api\_password) | Value of XE\_API\_PASSWORD for the tariff backend. | `string` | n/a | yes |
| <a name="input_tariff_backend_xe_api_username"></a> [tariff\_backend\_xe\_api\_username](#input\_tariff\_backend\_xe\_api\_username) | Value of XE\_API\_USERNAME for the tariff backend. | `string` | n/a | yes |
| <a name="input_tariff_backend_xi_sync_host"></a> [tariff\_backend\_xi\_sync\_host](#input\_tariff\_backend\_xi\_sync\_host) | Value of Tariff Sync host. | `string` | n/a | yes |
| <a name="input_tariff_backend_xi_sync_password"></a> [tariff\_backend\_xi\_sync\_password](#input\_tariff\_backend\_xi\_sync\_password) | Value of Tariff Sync password. | `string` | n/a | yes |
| <a name="input_tariff_backend_xi_sync_username"></a> [tariff\_backend\_xi\_sync\_username](#input\_tariff\_backend\_xi\_sync\_username) | Value of Tariff Sync username. | `string` | n/a | yes |
| <a name="input_waf_rpm_limit"></a> [waf\_rpm\_limit](#input\_waf\_rpm\_limit) | Request per minute limit for the WAF. | `number` | `5000` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
