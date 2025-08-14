<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.firehose_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.nr_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `""` | no |
| <a name="input_firehose_backups_bucket"></a> [firehose\_backups\_bucket](#input\_firehose\_backups\_bucket) | ARN of the S3 bucket for failed Firehose metrics | `string` | n/a | yes |
| <a name="input_newrelic_datacenter"></a> [newrelic\_datacenter](#input\_newrelic\_datacenter) | US or EU datacenter ('US' or 'EU') | `string` | `"EU"` | no |
| <a name="input_newrelic_license_key"></a> [newrelic\_license\_key](#input\_newrelic\_license\_key) | New Relic ingest license key | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firehose_arn"></a> [firehose\_arn](#output\_firehose\_arn) | n/a |
<!-- END_TF_DOCS -->