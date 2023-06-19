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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../../common/acm/ | n/a |
| <a name="module_alb-security-group"></a> [alb-security-group](#module\_alb-security-group) | ../../common/security-group/ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | Vpc Cidr Block | `string` | `"10.0.0.0/16"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the test Domain | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"development"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
