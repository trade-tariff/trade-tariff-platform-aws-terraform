# elasticache-redis

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [random_password.auth_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes to the replication group immediately (`true`), or to wait for the next maintenance window (`false`). | `bool` | `true` | no |
| <a name="input_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#input\_at\_rest\_encryption\_enabled) | Encryption at rest. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Automatic upgrade of minor versions. | `bool` | `true` | no |
| <a name="input_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#input\_automatic\_failover\_enabled) | Redis automatic failover configuration. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Redis cluster description | `string` | n/a | yes |
| <a name="input_log_delivery_configuration"></a> [log\_delivery\_configuration](#input\_log\_delivery\_configuration) | Log delivery configuration for redis cluster. | <pre>list(object({<br>    destination_type = string<br>    destination      = string<br>    log_format       = string<br>    log_type         = string<br>  }))</pre> | `[]` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The weekly time range for maintenance periods on the cluster. Format: `ddd:hh22:mi-ddd:hh23:mi` (UTC). Minimum period must be 60 minutes. For example, `sun:05:00-sun:06:00`. | `string` | n/a | yes |
| <a name="input_multi_az_enabled"></a> [multi\_az\_enabled](#input\_multi\_az\_enabled) | Redis multi-az configuration. | `bool` | `true` | no |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | Instance type, i.e. `cache.t3.small`. | `string` | n/a | yes |
| <a name="input_num_node_groups"></a> [num\_node\_groups](#input\_num\_node\_groups) | Number of node groups. | `string` | n/a | yes |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Parameter group for replication group. For example, `default.redis7`. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Redis port number. | `number` | `6379` | no |
| <a name="input_preferred_cache_cluster_azs"></a> [preferred\_cache\_cluster\_azs](#input\_preferred\_cache\_cluster\_azs) | Availability zones to spread the nodes. | `list(string)` | `null` | no |
| <a name="input_replicas_per_node_group"></a> [replicas\_per\_node\_group](#input\_replicas\_per\_node\_group) | Number of replicas per node group. | `string` | n/a | yes |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | Name of the replication group. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the group. | `list(string)` | `null` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | Number of days of snapshots to retain. Defaults to `7`. | `number` | `7` | no |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | Daily time range during which ElastiCache will take a snapshot of the cache cluster. Minimum time of 60 minutes. For example: `05:00-06:00`. | `string` | n/a | yes |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of the subnet group to be used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all taggable resources. | `map(string)` | `{}` | no |
| <a name="input_transit_encryption_enabled"></a> [transit\_encryption\_enabled](#input\_transit\_encryption\_enabled) | Encryption in transit. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_endpoint"></a> [primary\_endpoint](#output\_primary\_endpoint) | Connection string primary endpoint. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | Connection string primary endpoint. |
<!-- END_TF_DOCS -->
