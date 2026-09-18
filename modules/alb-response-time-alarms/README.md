# alb-response-time-alarms

CloudWatch average response-time alarms for ALB target groups.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.37.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.37.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.long_response_times](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topic ARNs notified when a response-time alarm fires. | `list(string)` | `[]` | no |
| <a name="input_default_threshold"></a> [default\_threshold](#input\_default\_threshold) | Average TargetResponseTime threshold in seconds for target groups without an override. | `number` | `1.5` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name included in alarm descriptions. | `string` | n/a | yes |
| <a name="input_load_balancer_arn_suffix"></a> [load\_balancer\_arn\_suffix](#input\_load\_balancer\_arn\_suffix) | ARN suffix of the load balancer that owns the target groups. | `string` | n/a | yes |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | ALB target groups to alarm on, keyed by target group name. | <pre>map(object({<br/>    name       = string<br/>    arn        = string<br/>    arn_suffix = string<br/>  }))</pre> | n/a | yes |
| <a name="input_thresholds"></a> [thresholds](#input\_thresholds) | Per target-group average TargetResponseTime thresholds in seconds. Unlisted target groups use default\_threshold. | `map(number)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
