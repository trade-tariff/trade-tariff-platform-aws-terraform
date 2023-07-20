## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | ../../common/dynamodb | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../../common/acm/ | n/a |
| <a name="module_admin_bearer_token"></a> [admin\_bearer\_token](#module\_admin\_bearer\_token) | ../../common/secret/ | n/a |
| <a name="module_admin_oauth_id"></a> [admin\_oauth\_id](#module\_admin\_oauth\_id) | ../../common/secret/ | n/a |
| <a name="module_admin_oauth_secret"></a> [admin\_oauth\_secret](#module\_admin\_oauth\_secret) | ../../common/secret/ | n/a |
| <a name="module_admin_secret_key_base"></a> [admin\_secret\_key\_base](#module\_admin\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_alb"></a> [alb](#module\_alb) | ../../common/application-load-balancer/ | n/a |
| <a name="module_alb-security-group"></a> [alb-security-group](#module\_alb-security-group) | ../../common/security-group/ | n/a |
| <a name="module_backend_oauth_id"></a> [backend\_oauth\_id](#module\_backend\_oauth\_id) | ../../common/secret/ | n/a |
| <a name="module_backend_oauth_secret"></a> [backend\_oauth\_secret](#module\_backend\_oauth\_secret) | ../../common/secret/ | n/a |
| <a name="module_backend_secret_key_base"></a> [backend\_secret\_key\_base](#module\_backend\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_backend_sentry_dsn"></a> [backend\_sentry\_dsn](#module\_backend\_sentry\_dsn) | ../../common/secret/ | n/a |
| <a name="module_backend_sync_email"></a> [backend\_sync\_email](#module\_backend\_sync\_email) | ../../common/secret/ | n/a |
| <a name="module_backend_sync_host"></a> [backend\_sync\_host](#module\_backend\_sync\_host) | ../../common/secret/ | n/a |
| <a name="module_backend_sync_password"></a> [backend\_sync\_password](#module\_backend\_sync\_password) | ../../common/secret/ | n/a |
| <a name="module_backend_sync_username"></a> [backend\_sync\_username](#module\_backend\_sync\_username) | ../../common/secret/ | n/a |
| <a name="module_cloudwatch"></a> [cloudwatch](#module\_cloudwatch) | ../../common/cloudwatch/ | n/a |
| <a name="module_duty_calculator_secret_key_base"></a> [duty\_calculator\_secret\_key\_base](#module\_duty\_calculator\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../common/ecr/ | n/a |
| <a name="module_frontend_secret_key_base"></a> [frontend\_secret\_key\_base](#module\_frontend\_secret\_key\_base) | ../../common/secret/ | n/a |
| <a name="module_logs"></a> [logs](#module\_logs) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_newrelic_license_key"></a> [newrelic\_license\_key](#module\_newrelic\_license\_key) | ../../common/secret/ | n/a |
| <a name="module_opensearch"></a> [opensearch](#module\_opensearch) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/opensearch | aws/opensearch-v1.1.0 |
| <a name="module_opensearch_packages_bucket"></a> [opensearch\_packages\_bucket](#module\_opensearch\_packages\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../common/rds | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ../../common/elasticache/ | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ../../common/s3 | n/a |
| <a name="module_search_configuration_bucket"></a> [search\_configuration\_bucket](#module\_search\_configuration\_bucket) | git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git | v3.14.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_kms_alias.opensearch_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secretsmanager_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.opensearch_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.secretsmanager_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_secretsmanager_secret.postgres_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.redis_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.postgres_connection_string_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.redis_connection_string_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_parameter.ecr_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.opensearch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_bearer_token"></a> [admin\_bearer\_token](#input\_admin\_bearer\_token) | Value of BEARER\_TOKEN for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_oauth_id"></a> [admin\_oauth\_id](#input\_admin\_oauth\_id) | Value of TARIFF\_ADMIN\_OAUTH\_ID for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_oauth_secret"></a> [admin\_oauth\_secret](#input\_admin\_oauth\_secret) | Value of TARIFF\_ADMIN\_OAUTH\_SECRET for the admin tool. | `string` | n/a | yes |
| <a name="input_admin_secret_key_base"></a> [admin\_secret\_key\_base](#input\_admin\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the admin tool. | `string` | n/a | yes |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The name of the alb | `string` | `"trade-tariff-alb"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Development Account ID. | `string` | `"844815912454"` | no |
| <a name="input_backend_secret_key_base"></a> [backend\_secret\_key\_base](#input\_backend\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the backend. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the test Domain | `string` | `"transformtariff.co.uk"` | no |
| <a name="input_duty_calculator_secret_key_base"></a> [duty\_calculator\_secret\_key\_base](#input\_duty\_calculator\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the duty calculator. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"development"` | no |
| <a name="input_frontend_secret_key_base"></a> [frontend\_secret\_key\_base](#input\_frontend\_secret\_key\_base) | Value of SECRET\_KEY\_BASE for the frontend. | `string` | n/a | yes |
| <a name="input_newrelic_license_key"></a> [newrelic\_license\_key](#input\_newrelic\_license\_key) | License key for NewRelic. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_s3_tags"></a> [s3\_tags](#input\_s3\_tags) | Tags | `map(string)` | <pre>{<br>  "Billing": "TRN.HMR11896",<br>  "Environment": "development",<br>  "Project": "trade-tariff"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | <pre>{<br>  "Terraform": true<br>}</pre> | no |
| <a name="input_tariff_backend_oauth_id"></a> [tariff\_backend\_oauth\_id](#input\_tariff\_backend\_oauth\_id) | Value of Tariff Backend OAuth ID. | `string` | n/a | yes |
| <a name="input_tariff_backend_oauth_secret"></a> [tariff\_backend\_oauth\_secret](#input\_tariff\_backend\_oauth\_secret) | Value of Tariff Backend OAuth secret. | `string` | n/a | yes |
| <a name="input_tariff_backend_sentry_dsn"></a> [tariff\_backend\_sentry\_dsn](#input\_tariff\_backend\_sentry\_dsn) | Value of Backend Sentry DSN. | `string` | n/a | yes |
| <a name="input_tariff_backend_sync_email"></a> [tariff\_backend\_sync\_email](#input\_tariff\_backend\_sync\_email) | Value of Tariff Sync email. | `string` | n/a | yes |
| <a name="input_tariff_backend_sync_host"></a> [tariff\_backend\_sync\_host](#input\_tariff\_backend\_sync\_host) | Value of Tariff Sync host. | `string` | n/a | yes |
| <a name="input_tariff_backend_sync_password"></a> [tariff\_backend\_sync\_password](#input\_tariff\_backend\_sync\_password) | Value of Tariff Sync password. | `string` | n/a | yes |
| <a name="input_tariff_backend_sync_username"></a> [tariff\_backend\_sync\_username](#input\_tariff\_backend\_sync\_username) | Value of Tariff Sync username. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
