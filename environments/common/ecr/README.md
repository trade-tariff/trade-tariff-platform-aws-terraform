# ecr

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.trade_tariff_ecr_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_kms_key.ecr_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
