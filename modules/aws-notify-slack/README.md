This module is derived from official terraform module https://github.com/terraform-aws-modules/terraform-aws-notify-slack with a minor fix for IAM policy.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.99.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | terraform-aws-modules/lambda/aws | 3.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.sns_feedback_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.sns_notify_slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting log data for Lambda | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in log group for Lambda. | `number` | `0` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch\_log\_group\_tags](#input\_cloudwatch\_log\_group\_tags) | Additional tags for the Cloudwatch log group | `map(string)` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create all resources | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create new SNS topic | `bool` | `true` | no |
| <a name="input_enable_sns_topic_delivery_status_logs"></a> [enable\_sns\_topic\_delivery\_status\_logs](#input\_enable\_sns\_topic\_delivery\_status\_logs) | Whether to enable SNS topic delivery status logs | `bool` | `false` | no |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | Path of policies to that should be added to IAM role for Lambda Function | `string` | `null` | no |
| <a name="input_iam_role_boundary_policy_arn"></a> [iam\_role\_boundary\_policy\_arn](#input\_iam\_role\_boundary\_policy\_arn) | The ARN of the policy that is used to set the permissions boundary for the role | `string` | `null` | no |
| <a name="input_iam_role_name_prefix"></a> [iam\_role\_name\_prefix](#input\_iam\_role\_name\_prefix) | A unique role name beginning with the specified prefix | `string` | `"lambda"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of IAM role to use for Lambda Function | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | Additional tags for the IAM role | `map(string)` | `{}` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used for decrypting slack webhook url | `string` | `""` | no |
| <a name="input_lambda_attach_dead_letter_policy"></a> [lambda\_attach\_dead\_letter\_policy](#input\_lambda\_attach\_dead\_letter\_policy) | Controls whether SNS/SQS dead letter notification policy should be added to IAM role for Lambda Function | `bool` | `false` | no |
| <a name="input_lambda_dead_letter_target_arn"></a> [lambda\_dead\_letter\_target\_arn](#input\_lambda\_dead\_letter\_target\_arn) | The ARN of an SNS topic or SQS queue to notify when an invocation fails. | `string` | `null` | no |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | The description of the Lambda function | `string` | `null` | no |
| <a name="input_lambda_function_ephemeral_storage_size"></a> [lambda\_function\_ephemeral\_storage\_size](#input\_lambda\_function\_ephemeral\_storage\_size) | Amount of ephemeral storage (/tmp) in MB your Lambda Function can use at runtime. Valid value between 512 MB to 10,240 MB (10 GB). | `number` | `512` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | The name of the Lambda function to create | `string` | `"notify_slack"` | no |
| <a name="input_lambda_function_s3_bucket"></a> [lambda\_function\_s3\_bucket](#input\_lambda\_function\_s3\_bucket) | S3 bucket to store artifacts | `string` | `null` | no |
| <a name="input_lambda_function_store_on_s3"></a> [lambda\_function\_store\_on\_s3](#input\_lambda\_function\_store\_on\_s3) | Whether to store produced artifacts on S3 or locally. | `bool` | `false` | no |
| <a name="input_lambda_function_tags"></a> [lambda\_function\_tags](#input\_lambda\_function\_tags) | Additional tags for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_lambda_function_vpc_security_group_ids"></a> [lambda\_function\_vpc\_security\_group\_ids](#input\_lambda\_function\_vpc\_security\_group\_ids) | List of security group ids when Lambda Function should run in the VPC. | `list(string)` | `null` | no |
| <a name="input_lambda_function_vpc_subnet_ids"></a> [lambda\_function\_vpc\_subnet\_ids](#input\_lambda\_function\_vpc\_subnet\_ids) | List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets. | `list(string)` | `null` | no |
| <a name="input_lambda_role"></a> [lambda\_role](#input\_lambda\_role) | IAM role attached to the Lambda Function.  If this is set then a role will not be created for you. | `string` | `""` | no |
| <a name="input_lambda_source_path"></a> [lambda\_source\_path](#input\_lambda\_source\_path) | The source path of the custom Lambda function | `string` | `null` | no |
| <a name="input_log_events"></a> [log\_events](#input\_log\_events) | Boolean flag to enabled/disable logging of incoming events | `bool` | `false` | no |
| <a name="input_recreate_missing_package"></a> [recreate\_missing\_package](#input\_recreate\_missing\_package) | Whether to recreate missing Lambda package if it is missing locally or not | `bool` | `true` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations | `number` | `-1` | no |
| <a name="input_slack_channel"></a> [slack\_channel](#input\_slack\_channel) | The name of the channel in Slack for notifications | `string` | n/a | yes |
| <a name="input_slack_emoji"></a> [slack\_emoji](#input\_slack\_emoji) | A custom emoji that will appear on Slack messages | `string` | `":aws:"` | no |
| <a name="input_slack_username"></a> [slack\_username](#input\_slack\_username) | The username that will appear on Slack messages | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | The URL of Slack webhook | `string` | n/a | yes |
| <a name="input_sns_topic_feedback_role_description"></a> [sns\_topic\_feedback\_role\_description](#input\_sns\_topic\_feedback\_role\_description) | Description of IAM role to use for SNS topic delivery status logging | `string` | `null` | no |
| <a name="input_sns_topic_feedback_role_force_detach_policies"></a> [sns\_topic\_feedback\_role\_force\_detach\_policies](#input\_sns\_topic\_feedback\_role\_force\_detach\_policies) | Specifies to force detaching any policies the IAM role has before destroying it. | `bool` | `true` | no |
| <a name="input_sns_topic_feedback_role_name"></a> [sns\_topic\_feedback\_role\_name](#input\_sns\_topic\_feedback\_role\_name) | Name of the IAM role to use for SNS topic delivery status logging | `string` | `null` | no |
| <a name="input_sns_topic_feedback_role_path"></a> [sns\_topic\_feedback\_role\_path](#input\_sns\_topic\_feedback\_role\_path) | Path of IAM role to use for SNS topic delivery status logging | `string` | `null` | no |
| <a name="input_sns_topic_feedback_role_permissions_boundary"></a> [sns\_topic\_feedback\_role\_permissions\_boundary](#input\_sns\_topic\_feedback\_role\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the IAM role used by SNS topic delivery status logging | `string` | `null` | no |
| <a name="input_sns_topic_feedback_role_tags"></a> [sns\_topic\_feedback\_role\_tags](#input\_sns\_topic\_feedback\_role\_tags) | A map of tags to assign to IAM the SNS topic feedback role | `map(string)` | `{}` | no |
| <a name="input_sns_topic_kms_key_id"></a> [sns\_topic\_kms\_key\_id](#input\_sns\_topic\_kms\_key\_id) | ARN of the KMS key used for enabling SSE on the topic | `string` | `""` | no |
| <a name="input_sns_topic_lambda_feedback_role_arn"></a> [sns\_topic\_lambda\_feedback\_role\_arn](#input\_sns\_topic\_lambda\_feedback\_role\_arn) | IAM role for SNS topic delivery status logs.  If this is set then a role will not be created for you. | `string` | `""` | no |
| <a name="input_sns_topic_lambda_feedback_sample_rate"></a> [sns\_topic\_lambda\_feedback\_sample\_rate](#input\_sns\_topic\_lambda\_feedback\_sample\_rate) | The percentage of successful deliveries to log | `number` | `100` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | The name of the SNS topic to create | `string` | n/a | yes |
| <a name="input_sns_topic_tags"></a> [sns\_topic\_tags](#input\_sns\_topic\_tags) | Additional tags for the SNS topic | `map(string)` | `{}` | no |
| <a name="input_subscription_filter_policy"></a> [subscription\_filter\_policy](#input\_subscription\_filter\_policy) | (Optional) A valid filter policy that will be used in the subscription to filter messages seen by the target resource. | `string` | `null` | no |
| <a name="input_subscription_filter_policy_scope"></a> [subscription\_filter\_policy\_scope](#input\_subscription\_filter\_policy\_scope) | (Optional) A valid filter policy scope MessageAttributes\|MessageBody | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_cloudwatch_log_group_arn"></a> [lambda\_cloudwatch\_log\_group\_arn](#output\_lambda\_cloudwatch\_log\_group\_arn) | The Amazon Resource Name (ARN) specifying the log group |
| <a name="output_lambda_iam_role_arn"></a> [lambda\_iam\_role\_arn](#output\_lambda\_iam\_role\_arn) | The ARN of the IAM role used by Lambda function |
| <a name="output_lambda_iam_role_name"></a> [lambda\_iam\_role\_name](#output\_lambda\_iam\_role\_name) | The name of the IAM role used by Lambda function |
| <a name="output_notify_slack_lambda_function_arn"></a> [notify\_slack\_lambda\_function\_arn](#output\_notify\_slack\_lambda\_function\_arn) | The ARN of the Lambda function |
| <a name="output_notify_slack_lambda_function_invoke_arn"></a> [notify\_slack\_lambda\_function\_invoke\_arn](#output\_notify\_slack\_lambda\_function\_invoke\_arn) | The ARN to be used for invoking Lambda function from API Gateway |
| <a name="output_notify_slack_lambda_function_last_modified"></a> [notify\_slack\_lambda\_function\_last\_modified](#output\_notify\_slack\_lambda\_function\_last\_modified) | The date Lambda function was last modified |
| <a name="output_notify_slack_lambda_function_name"></a> [notify\_slack\_lambda\_function\_name](#output\_notify\_slack\_lambda\_function\_name) | The name of the Lambda function |
| <a name="output_notify_slack_lambda_function_version"></a> [notify\_slack\_lambda\_function\_version](#output\_notify\_slack\_lambda\_function\_version) | Latest published version of your Lambda function |
| <a name="output_slack_topic_arn"></a> [slack\_topic\_arn](#output\_slack\_topic\_arn) | The ARN of the SNS topic from which messages will be sent to Slack |
| <a name="output_sns_topic_feedback_role_arn"></a> [sns\_topic\_feedback\_role\_arn](#output\_sns\_topic\_feedback\_role\_arn) | The Amazon Resource Name (ARN) of the IAM role used for SNS delivery status logging |
| <a name="output_this_slack_topic_arn"></a> [this\_slack\_topic\_arn](#output\_this\_slack\_topic\_arn) | The ARN of the SNS topic from which messages will be sent to Slack (backward compatibility for version 4.x) |
<!-- END_TF_DOCS -->
