# RDS Module

Creates an AWS RDS instance.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.rds_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.master_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.private_subnet_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Storage to allocate initially to the instance in gibibytes (i.e. 2^30 bytes). Can autoscale. | `number` | `5` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Amount of time, in days, (between 0 and 35) that backups should be retained for. | `number` | `30` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled, eg: `09:46-10:16` | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to protect the database from deletion. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine to use. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version of the database engine to use. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the database. See https://aws.amazon.com/rds/instance-types/ | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The time window (in UTC) to perform maintenance in. Syntax: `ddd:hh24:mi-ddd:hh24:mi`, eg: `Mon:00:00-Mon:01:30`. | `string` | n/a | yes |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum allocated storage for the instance. Defaults to `null` (no autoscaling). | `number` | `1` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | If the RDS instance is multi-AZ. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the database. | `string` | n/a | yes |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time, in days, (minimum 7, maximum 731, or any multiple of 31) to retain performance insights data. | `number` | `31` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | A list of private subnet IDs | `list(string)` | n/a | yes |
| <a name="input_secret_kms_key_arn"></a> [secret\_kms\_key\_arn](#input\_secret\_kms\_key\_arn) | ARN of the KMS Key to use to encrypt the connection string secret. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate with this RDS instance. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all taggable resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_arn"></a> [db\_arn](#output\_db\_arn) | ARN of the RDS instance. |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | Connection endpoint for the RDS instance. Format: `address:port`. |
| <a name="output_db_id"></a> [db\_id](#output\_db\_id) | ID of the RDS instance. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS Key created to encrypt database performance insights data. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | Globally unique ID of the KMS Key created to encrypt database performance insights data. |
| <a name="output_userless_connection_string"></a> [userless\_connection\_string](#output\_userless\_connection\_string) | A userless connection string (just the host and options) to use downstream. |
<!-- END_TF_DOCS -->
