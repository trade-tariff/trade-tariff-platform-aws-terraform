# AWS ElastiCache Module

A module to create a Redis cluster.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes to the replication group immediately (`true`), or to wait for the next maintenance window (`false`). | `bool` | `false` | no |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | Cloudwatch log group name for logs to flow into. | `string` | n/a | yes |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Name of the replication group. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type, i.e. `cache.t3.small`. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The weekly time range for maintenance periods on the cluster. Format: `ddd:hh22:mi-ddd:hh23:mi` (UTC). Minimum period must be 60 minutes. For example, `sun:05:00-sun:06:00`. | `string` | n/a | yes |
| <a name="input_parameter_group"></a> [parameter\_group](#input\_parameter\_group) | Parameter group for replication group. For example, `default.redis5.0`. | `string` | n/a | yes |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | Engine version to use. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the group. | `list(string)` | `null` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | Number of days of snapshots to retain. Defaults to `7`. | `number` | `7` | no |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | Daily time range during which ElastiCache will take a snapshot of the cache cluster. Minimum time of 60 minutes. For example: `05:00-06:00`. | `string` | n/a | yes |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of the subnet group to be used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Connection string of the cluster. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
