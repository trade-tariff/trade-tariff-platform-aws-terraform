# GOV.UK Online Trade Tariff (OTT) Infrastructure

This repository defines AWS infrastructure for the Online Trade Tariff service.
Terraform modules live in [modules/](modules/). Terragrunt configurations under
[environments/](environments/) select resources for each environment.

This is not an application checkout. Planning needs approved AWS access and may
read remote state. Applying changes affects shared services.

## Prerequisites

- Terraform [v1.10](https://github.com/hashicorp/terraform/releases/tag/v1.10)
or a compatible version of [OpenTofu](https://github.com/opentofu/opentofu)
- Terragrunt >= [v0.73](https://github.com/gruntwork-io/terragrunt/releases)

## Making changes

To make changes to the infrastructure, modify files under the relevant `environments/`
subdirectory. Read [CONTRIBUTING.md](CONTRIBUTING.md) before starting.

- After confirming the AWS account and target environment, initialise modules
  from the intended Terragrunt root, not the repository root

```shell
export DISABLE_INIT=true
terragrunt run --all init
```

- Install and run the [`pre-commit`](https://pre-commit.com/) hooks when making
changes. These keep the Terraform documentation up to date, prevent linting
errors, and ensure your changes conform to the repository standards.

- Run Terraform module tests when changing module behaviour:

```shell
scripts/run-terraform-tests
```

Module tests live in `modules/<module>/tests/*.tftest.hcl`. Prefer fast
plan-time tests that assert module contracts, defaults, and derived resource
configuration. Avoid tests that create real AWS infrastructure; deployment
confidence still comes from the Terragrunt plan and apply workflow.
See [Testing Terraform](https://transformuk.atlassian.net/wiki/spaces/HO/pages/23325048844/Testing+Terraform) on Confluence for the full approach.

- Opening a pull request triggers plans and an automatic apply to shared
  development. Review [the workflow](.github/workflows/deploy-to-development.yml)
  before opening it. A successful apply is not proof that application behaviour
  is correct.

- Merges into `main` will deploy the changes into the staging environment, with
a manual approval step required for production.

## Licence

The repository uses the [MIT licence](LICENSE), with the existing Transform UK
copyright notice. Preserve that notice. State, credentials and private
configuration are not covered by permission to reuse this code.
