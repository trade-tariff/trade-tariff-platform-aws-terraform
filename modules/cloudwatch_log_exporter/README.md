This module is derived from https://github.com/DNXLabs/terraform-aws-log-exporter/ with minor changes.
It creates a lambda function that exports log groups on the AWS account and region deployed(default every 4 hours).

It will only export each log group if it has the tag ExportToS3=true, if the last export was more than 24 hours ago it creates an export task to the S3_BUCKET defined saving the current timestamp in a SSM parameter.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.log_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.log_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.log_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.log_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.log_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.log_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.log_exporter](https://registry.terraform.io/providers/hashicorp/archive/2.4.0/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_export_bucket"></a> [cloudwatch\_logs\_export\_bucket](#input\_cloudwatch\_logs\_export\_bucket) | Bucket to export logs | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
