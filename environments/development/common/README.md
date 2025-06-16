## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | ../../dynamodb | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | < 5.98.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | 5.97.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../../../modules/acm/ | n/a |
| <a name="module_acm_london"></a> [acm\_london](#module\_acm\_london) | ../../../modules/acm/ | n/a |
| <a name="module_acm_origin"></a> [acm\_origin](#module\_acm\_origin) | ../../../modules/acm | n/a |
| <a name="module_acm_preview"></a> [acm\_preview](#module\_acm\_preview) | ../../../modules/acm | n/a |
| <a name="module_admin_configuration"></a> [admin\_configuration](#module\_admin\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_admin_connection_string"></a> [admin\_connection\_string](#module\_admin\_connection\_string) | ../../../modules/secret/ | n/a |
| <a name="module_alb"></a> [alb](#module\_alb) | ../../../modules/application-load-balancer/ | n/a |
| <a name="module_alb-security-group"></a> [alb-security-group](#module\_alb-security-group) | ../../../modules/security-group/ | n/a |
| <a name="module_alb_preview"></a> [alb\_preview](#module\_alb\_preview) | ../../../modules/application-load-balancer/ | n/a |
| <a name="module_api_cdn"></a> [api\_cdn](#module\_api\_cdn) | ../../../modules/cloudfront | n/a |
| <a name="module_backend_uk_api_configuration"></a> [backend\_uk\_api\_configuration](#module\_backend\_uk\_api\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_backend_uk_worker_configuration"></a> [backend\_uk\_worker\_configuration](#module\_backend\_uk\_worker\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_backend_xi_api_configuration"></a> [backend\_xi\_api\_configuration](#module\_backend\_xi\_api\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_backend_xi_worker_configuration"></a> [backend\_xi\_worker\_configuration](#module\_backend\_xi\_worker\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_backups_basic_auth"></a> [backups\_basic\_auth](#module\_backups\_basic\_auth) | ../../../modules/secret/ | n/a |
| <a name="module_backups_cdn"></a> [backups\_cdn](#module\_backups\_cdn) | ../../../modules/cloudfront | n/a |
| <a name="module_cdn"></a> [cdn](#module\_cdn) | ../../../modules/cloudfront | n/a |
| <a name="module_cloudwatch"></a> [cloudwatch](#module\_cloudwatch) | ../../../modules/cloudwatch/ | n/a |
| <a name="module_cloudwatch-logs-exporter"></a> [cloudwatch-logs-exporter](#module\_cloudwatch-logs-exporter) | ../../../modules/cloudwatch_log_exporter | n/a |
| <a name="module_commodi_tea_cognito"></a> [commodi\_tea\_cognito](#module\_commodi\_tea\_cognito) | ../../../modules/cognito | n/a |
| <a name="module_commodi_tea_configuration"></a> [commodi\_tea\_configuration](#module\_commodi\_tea\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_create_auth_challenge"></a> [create\_auth\_challenge](#module\_create\_auth\_challenge) | ../../../modules/lambda | n/a |
| <a name="module_db_replicate_configuration"></a> [db\_replicate\_configuration](#module\_db\_replicate\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_define_auth_challenge"></a> [define\_auth\_challenge](#module\_define\_auth\_challenge) | ../../../modules/lambda | n/a |
| <a name="module_dev_hub_configuration"></a> [dev\_hub\_configuration](#module\_dev\_hub\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_duty_calculator_configuration"></a> [duty\_calculator\_configuration](#module\_duty\_calculator\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_fpo_search_configuration"></a> [fpo\_search\_configuration](#module\_fpo\_search\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_fpo_search_training_pem"></a> [fpo\_search\_training\_pem](#module\_fpo\_search\_training\_pem) | ../../../modules/secret/ | n/a |
| <a name="module_frontend_configuration"></a> [frontend\_configuration](#module\_frontend\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_identity_configuration"></a> [identity\_configuration](#module\_identity\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_identity_create_auth_challenge_configuration"></a> [identity\_create\_auth\_challenge\_configuration](#module\_identity\_create\_auth\_challenge\_configuration) | ../../../modules/secret/ | n/a |
| <a name="module_logs"></a> [logs](#module\_logs) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v4.5.0 |
| <a name="module_identity_cognito"></a> [identity\_cognito](#module\_identity\_cognito) | ../../../modules/cognito | n/a |
| <a name="module_notify_slack"></a> [notify\_slack](#module\_notify\_slack) | ../../../modules/aws-notify-slack | n/a |
| <a name="module_opensearch"></a> [opensearch](#module\_opensearch) | ../../../modules/opensearch | n/a |
| <a name="module_opensearch_packages_bucket"></a> [opensearch\_packages\_bucket](#module\_opensearch\_packages\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v4.6.0 |
| <a name="module_postgres_admin_aurora"></a> [postgres\_admin\_aurora](#module\_postgres\_admin\_aurora) | ../../../modules/rds_cluster | n/a |
| <a name="module_postgres_aurora"></a> [postgres\_aurora](#module\_postgres\_aurora) | ../../../modules/rds_cluster | n/a |
| <a name="module_postgres_commodi_tea"></a> [postgres\_commodi\_tea](#module\_postgres\_commodi\_tea) | ../../../modules/rds | n/a |
| <a name="module_postgres_developer_hub"></a> [postgres\_developer\_hub](#module\_postgres\_developer\_hub) | ../../../modules/rds | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ../../../modules/elasticache-redis/ | n/a |
| <a name="module_reporting_cdn"></a> [reporting\_cdn](#module\_reporting\_cdn) | ../../../modules/cloudfront | n/a |
| <a name="module_rw_aurora_connection_string"></a> [rw\_aurora\_connection\_string](#module\_rw\_aurora\_connection\_string) | ../../../modules/secret/ | n/a |
| <a name="module_search_configuration_bucket"></a> [search\_configuration\_bucket](#module\_search\_configuration\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v4.6.0 |
| <a name="module_ses"></a> [ses](#module\_ses) | ../../../modules/ses | n/a |
| <a name="module_slack_notify_lambda_slack_webhook_url"></a> [slack\_notify\_lambda\_slack\_webhook\_url](#module\_slack\_notify\_lambda\_slack\_webhook\_url) | ../../../modules/secret/ | n/a |
| <a name="module_tea_cognito_client_id"></a> [tea\_cognito\_client\_id](#module\_tea\_cognito\_client\_id) | ../../../modules/secret/ | n/a |
| <a name="module_tea_cognito_client_secret"></a> [tea\_cognito\_client\_secret](#module\_tea\_cognito\_client\_secret) | ../../../modules/secret/ | n/a |
| <a name="module_tea_cognito_secret"></a> [tea\_cognito\_secret](#module\_tea\_cognito\_secret) | ../../../modules/secret/ | n/a |
| <a name="module_tech_docs_cdn"></a> [tech\_docs\_cdn](#module\_tech\_docs\_cdn) | ../../../modules/cloudfront | n/a |
| <a name="module_verify_auth_challenge"></a> [verify\_auth\_challenge](#module\_verify\_auth\_challenge) | ../../../modules/lambda | n/a |
| <a name="module_waf"></a> [waf](#module\_waf) | ../../../modules/waf | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.long_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_cache_policy.medium_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_cache_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_cache_policy.short_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_cache_policy.very_very_long_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_function.basic_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.forward_all_qsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_origin_request_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_response_headers_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cloudwatch_log_group.redis_engine_lg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.redis_slow_lg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_cloudwatch_metric_alarm.high_5xx_codes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.long_response_times](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_openid_connect_provider.github_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.ci_api_docs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_appendix5a_persistence_readwrite_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_build_ami_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_ecs_deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_fpo_models_secrets_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_lambda_deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_preview_app_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_reporting_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_tech_docs_persistence_readwrite_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ci_terraform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.appendix5a_ci_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.breakglass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ci_api_docs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ci_build_ami_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ci_ecs_deployments_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ci_preview_app_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ci_terraform_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.fpo_models_ci_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.reporting_ci_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.serverless_lambda_ci_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ses_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tech_docs_ci_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ses_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.api_docs_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.appendix5a_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.breakglass_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.build_ami_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ci_preview_app_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_deployments_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fpo_models_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_terraform_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.reporting_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.serverless_lambda_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tech_docs_ci_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
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
| [aws_route53_record.origin_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.origin_wildcard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.tea_cognito_custom_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.reporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.ses_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.tech_docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.redis_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.redis_reader_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.redis_connection_string_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.redis_reader_connection_string_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_parameter.ecr_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.tea_cognito_public_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_wafv2_web_acl_logging_configuration.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [random_password.origin_header](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.tea_cognito_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [archive_file.create_auth_challenge](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.define_auth_challenge](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.verify_auth_challenge](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudfront_cache_policy.caching_disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_iam_policy_document.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.breakglass_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ci_build_ami_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.reporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tech_docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.waf_log_group_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret_version.backups_basic_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.identity_create_auth_challenge_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.slack_notify_lambda_slack_webhook_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | n/a | `map(string)` | <pre>{<br>  "development": "844815912454",<br>  "production": "382373577178",<br>  "staging": "451934005581"<br>}</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the service. | `string` | `"dev.trade-tariff.service.gov.uk"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"development"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_waf_rpm_limit"></a> [waf\_rpm\_limit](#input\_waf\_rpm\_limit) | Request per minute limit for the WAF. This limit applies to our main CDN distribution and applies to all aliases on that CDN. | `number` | `2000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosted_zone_name_servers"></a> [hosted\_zone\_name\_servers](#output\_hosted\_zone\_name\_servers) | Name servers. |
<!-- END_TF_DOCS -->
