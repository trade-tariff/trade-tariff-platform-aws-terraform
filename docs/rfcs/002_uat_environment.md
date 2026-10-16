# Request for Change (RFC): On-demand UAT environment

## Overview

This RFC proposes a UAT environment that mirrors production. A start job creates it on demand and a shut-down job destroys it. It is public on `uat.trade-tariff.service.gov.uk`, sits behind basic auth, and has no WAF rules.

- **Ticket**: [HMRC-2759](https://transformuk.atlassian.net/browse/HMRC-2759)
- **Related**: HMRC-1858 (earlier test environment discussion), HMRC-2648 (alarm routing)

## Decisions

| Topic | Decision |
|-------|----------|
| AWS account | A new `UAT` account in the Infrastructure OU, managed in `trade-tariff-platform-terraform-aws-accounts`. |
| Lifecycle | Start runs `terragrunt apply`. Stop runs `terragrunt destroy`. There is no automatic expiry. |
| Data | Manual restore of the production dump with `bin/db-replicate`, the same as development and staging. |
| Domain | `uat.trade-tariff.service.gov.uk`, delegated from the production zone. |
| Access control | Basic auth in a CloudFront viewer-request function. Credentials are in Secrets Manager. |
| WAF | Not created. This is the only intended functional difference from production. |

## Design

### Layout

A new Terragrunt root `environments/uat` with four layers:

| Layer | Contents | Lifecycle |
|-------|----------|-----------|
| `bootstrap` | Route 53 zone `uat.trade-tariff.service.gov.uk`, ACM certificates (eu-west-2 and us-east-1), Secrets Manager secrets (including basic auth), KMS keys, Slack notifier, GitHub OIDC roles. | Applied once. Not destroyed by the stop job. |
| `base` | VPC, subnets, NAT gateways. | Start/stop |
| `common` | ALB, CloudFront, RDS Aurora, ElastiCache, OpenSearch, Cognito, S3, Lambdas, API Gateway (without WAF). | Start/stop |
| `applications` | ECS cluster and services. | Start/stop |

`base`, `common` and `applications` start as a copy of `environments/production`, with these changes:

- WAF resources (`waf.tf`, `gateway-waf.tf`, `backup-waf.tf`) are removed.
- Bootstrap resources are read from the `bootstrap` remote state instead of being created.
- Account-level security services (Security Hub, GuardDuty, Inspector, Config) move to `bootstrap`. They are not torn down with the workload.
- Production-only integrations are removed: New Relic metric stream, e2e metrics, ECR repositories (UAT pulls from the production ECR, as staging does).
- All S3 buckets set `force_destroy = true`, and RDS sets `skip_final_snapshot = true` and `deletion_protection = false`, so destroy leaves no orphans.

The bootstrap layer stays because DNS delegation, certificate validation and secret values must not churn on each start. Its standing cost is a few dollars a month (hosted zone, secrets, KMS keys).

### Component selection

`common` and `applications` take one variable:

```hcl
variable "components" {
  type        = set(string)
  description = "Components to create. Components not in the set are not created."
}
```

Each component's resources use `count` or `for_each` on membership of this set. The start job expands the selection with a dependency map before it calls Terragrunt, and it prints what it added.

| Component | Needs |
|-----------|-------|
| `frontend` | `backend` |
| `backend` (UK and XI APIs and workers) | `database`, `cache`, `search` |
| `admin` | `backend`, `identity` |
| `identity` | `cognito` |
| `dev-hub` | `identity`, `backend` |
| `flagsmith` | `database` |
| `mcp` | `backend` |

`database`, `cache`, `search` and `cognito` are internal components. Users do not select them directly.

### Start job

`.github/workflows/uat-start.yml` in this repository, triggered by `workflow_dispatch`:

1. Inputs: one boolean per selectable component, plus `replicate_database` (default `true`).
2. Expand dependencies and set `TF_VAR_components`.
3. `terragrunt apply` on `base`, then `common`, then `applications`.
4. Deploy the current production image tag of each selected service with the `deploy-ecs` reusable workflow in `trade-tariff-tools`.
5. If `replicate_database` is `true`, start `replicate-db-uat.yml` in `trade-tariff-backend`.
6. Post the URL and the selected components to Slack.

Running the start job again with a different selection adds or removes components in place.

### Stop job

`.github/workflows/uat-stop.yml`, triggered by `workflow_dispatch` with a required `confirm` input that must equal `uat`:

1. `terragrunt destroy` on `applications`, then `common`, then `base`.
2. Use the Resource Groups Tagging API to find resources with `Environment = uat` that are not in `bootstrap`. If any remain, fail the job and list them.
3. Post the result to Slack.

### Data

`bin/db-replicate` in `trade-tariff-backend` already restores the production dump into a target environment. The changes are:

- Add `uat` to `ACCOUNT_IDS`.
- Add `.github/workflows/replicate-db-uat.yml`, a copy of `replicate-db-staging.yml` with UAT values.
- Give the UAT account read access to the production persistence bucket (exchange rates and delta files), the same as staging.

### Basic auth

A CloudFront Function on viewer-request checks the `Authorization` header against the credentials in the `uat-basic-auth` secret. The function code is rendered at apply time, as staging does for `backups-basic-auth`.

API clients that send their own `Authorization: Bearer` header conflict with basic auth. For `/api/*` paths, the function also accepts an `X-UAT-Token` header with the same secret value. This is the only open question for review (see below).

### Alarms and notifications

- UAT Slack notifications go to `non-production-alerts`. Nothing goes to `production-alerts` or `production-observability` (HMRC-2648).
- A scheduled workflow runs each weekday. If the UAT ECS cluster has existed for more than 7 days, it posts a reminder to `non-production-alerts`. It does not stop the environment.

### Cost visibility

Every resource gets `Environment = uat` through the provider `default_tags`. The account is separate, so Cost Explorer shows UAT spend by linked account without extra work.

## Differences from production

| Area | Production | UAT |
|------|------------|-----|
| WAF | Enabled | Not created |
| Edge access | Public | Basic auth |
| Domain | `www.trade-tariff.service.gov.uk` | `uat.trade-tariff.service.gov.uk` |
| Alerts | `production-alerts` | `non-production-alerts` |
| Data | Live | Production dump, restored on request |
| New Relic metric stream | Enabled | Not created |
| RDS deletion protection, final snapshot | On | Off |

Instance sizes, task counts and service configuration are the same as production.

## Implementation plan

| # | Repository | Change |
|---|------------|--------|
| 1 | `trade-tariff-platform-terraform-aws-accounts` | Create the `UAT` account. Fix the account email template. |
| 2 | `trade-tariff-platform-aws-terraform` | This RFC. |
| 3 | `trade-tariff-platform-aws-terraform` | Manual bootstrap of the state bucket `terraform-state-uat-<account-id>`. Add `environments/uat/bootstrap`. Delegate `uat.` from the production zone. |
| 4 | `trade-tariff-platform-aws-terraform` | Add `environments/uat/{base,common,applications}` with the `components` variable. Allow the UAT account in the production ECR and persistence bucket policies. |
| 5 | `trade-tariff-platform-aws-terraform` | Add the `uat-start.yml`, `uat-stop.yml` and reminder workflows. |
| 6 | `trade-tariff-tools` | Add `uat` to `configure-environment`. |
| 7 | `trade-tariff-backend` | Add `uat` to `bin/db-replicate` and add `replicate-db-uat.yml`. |
| 8 | `trade-tariff-platform-aws-terraform` | Runbook: start, select components, get basic auth credentials, replicate data, stop. |

## Risks and mitigations

- **Drift from production**: `environments/uat` is a copy, so it can fall behind. Mitigation: pull request CI also plans `environments/uat`, and reviewers check `uat` when they change `production`. A later change can move shared code into modules.
- **Production data outside the production account**: the dump already goes to development and staging. UAT gets the same controls.
- **Failed destroy leaves resources**: the stop job checks for tagged resources and fails if any remain.
- **Forgotten environment**: the Slack reminder after 7 days.

## Open questions

1. Is an `X-UAT-Token` header for `/api/*` acceptable for API clients, or should API paths use an IP allow list?
2. Which team members can run the start and stop jobs? The proposal is: anyone with write access to this repository, through the `uat` GitHub environment.
