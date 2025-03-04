# GOV.UK Online Trade Tariff (OTT) Infrastructure

This repository stores the IaC (Terraform) for the OTT service.

## Prerequisites

- Terraform [v1.10](https://github.com/hashicorp/terraform/releases/tag/v1.10)
or a compatible version of [OpenTofu](https://github.com/opentofu/opentofu)
- Terragrunt >= [v0.73](https://github.com/gruntwork-io/terragrunt/releases)

## Making changes

To make changes to the infrastructure, modify files under the relevant `environment`
subdirectory.

- Initialise all of the modules in the terraform roots

```shell
export DISABLE_INIT=true
terragrunt run-all init
```

- Install and run the [`pre-commit`](https://pre-commit.com/) hooks when making
changes. These keep the Terraform documentation up to date, prevent linting
errors, and ensure your changes conform to the repository standards.

- Open a Pull Request with your changes. This will deploy the feature over the
development environment to proof that `terraform apply` runs without failure.

- Merges into `main` will deploy the changes into the staging environment, with
a manual approval step required for production.

## License

[MIT License](LICENSE)
