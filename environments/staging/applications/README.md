# applications

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | github.com/trade-tariff/terraform-aws-ecs | 57244e69abea685f7d45352abc994779b5f6d352 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.customer_api_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.organisations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_kms_key.log_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_service_discovery_private_dns_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment. | `string` | `"staging"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_namespace_arn"></a> [private\_dns\_namespace\_arn](#output\_private\_dns\_namespace\_arn) | ARN of the private DNS namespace. |
| <a name="output_private_dns_namespace_hosted_zone_id"></a> [private\_dns\_namespace\_hosted\_zone\_id](#output\_private\_dns\_namespace\_hosted\_zone\_id) | ID of the Route 53 zone for the private DNS namespace. |
| <a name="output_private_dns_namespace_id"></a> [private\_dns\_namespace\_id](#output\_private\_dns\_namespace\_id) | ID of the private DNS namespace. |
<!-- END_TF_DOCS -->
