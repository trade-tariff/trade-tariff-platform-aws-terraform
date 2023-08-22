# common

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.ecr_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | n/a | `map(string)` | <pre>{<br>  "development": "844815912454",<br>  "production": "382373577178",<br>  "staging": "451934005581"<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Staging environment. | `string` | `"staging"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to use. Defaults to `eu-west-2`. | `string` | `"eu-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | <pre>{<br>  "Terraform": true<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
