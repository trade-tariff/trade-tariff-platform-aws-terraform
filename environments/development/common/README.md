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
| <a name="module_alb"></a> [alb](#module\_alb) | ../../common/application-load-balancer/ | n/a |
| <a name="module_alb-security-group"></a> [alb-security-group](#module\_alb-security-group) | ../../common/security-group/ | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../common/ecr/ | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../common/rds | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ../../common/elasticache/ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The name of the alb | `string` | `"trade-tariff-alb"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Development Account ID. | `string` | `"844815912454"` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | Vpc Cidr Block | `string` | `"10.0.0.0/16"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the test Domain | `string` | `"transformtariff.co.uk"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"development"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | <pre>{<br>  "Terraform": true<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
