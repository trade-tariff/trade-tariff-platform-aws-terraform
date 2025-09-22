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
| [aws_cloudwatch_metric_stream.nr_metric_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [aws_iam_role.metric_stream_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.metric_stream_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | n/a | yes |
| <a name="input_firehose_arn"></a> [firehose\_arn](#input\_firehose\_arn) | The ARN of the Kinesis Firehose delivery stream | `string` | n/a | yes |
| <a name="input_include_metric_filters"></a> [include\_metric\_filters](#input\_include\_metric\_filters) | Map of inclusive metric filters. Use the namespace as the key and the list of metric names as the value. | `map(list(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metric_stream_name"></a> [metric\_stream\_name](#output\_metric\_stream\_name) | n/a |
<!-- END_TF_DOCS -->
