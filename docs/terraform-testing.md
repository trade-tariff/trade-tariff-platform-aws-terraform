# Testing Terraform

This document gives the approach for tests in the OTT Terraform code. It
applies to this repository and to
[`trade-tariff-platform-terraform-modules`](https://github.com/trade-tariff/trade-tariff-platform-terraform-modules).

## Summary

- Use the native `terraform test` framework with `mock_provider` and
  `command = plan`. These tests need no AWS credentials, create no
  infrastructure, and run in seconds.
- Test module contracts: variable validation, conditional resources, derived
  values, and the settings that keep data safe.
- Add a static security scan (Trivy) for modules and environment roots.
- Fix three gaps in the current checks. These gaps give false confidence
  today.
- Keep the development apply and the staging e2e tests as the final gate. Do
  not add tests that create real AWS resources.

## Current state

### What we check today

| Layer | Where | This repo | terraform-modules |
|-------|-------|-----------|-------------------|
| Format | pre-commit, CI | `terraform fmt`, `terragrunt hclfmt` | `terraform fmt` |
| Validate | pre-commit, CI | `terraform validate` | CI step (see gap 1) |
| Lint | pre-commit, CI | `tflint` with the AWS ruleset | not run |
| Module tests | `scripts/run-terraform-tests` in CI | 12 files, 3 modules | none |
| Plan | PR to development | plan for all three environments, posted as a PR comment | none |
| Apply | PR, then `main` | development on PR, staging on merge, production with approval | none |
| End-to-end | after staging apply | Playwright e2e suite | none |

The module tests that exist are good examples to copy:

- `modules/waf/tests/`: 10 files, 30 runs. They use `mock_provider`, assert
  on resource attributes, and use `expect_failures` for validation rules.
- `modules/elasticache/tests/replication_group.tftest.hcl`: 6 runs. Added
  with this document as a worked example.
- `modules/api-gateway/tests/cache_defaults.tftest.hcl`: 1 run. It asserts
  on variable defaults only, and it uses a real `aws` provider with fake
  credentials instead of `mock_provider`.

### Gaps

1. **The `terraform-modules` CI does not validate any module.** The
   `terraform validate` loop in `.github/workflows/ci.yml` runs from the
   repository root, so it validates the `aws/` directory. That directory has
   no `.tf` files. Terraform reports `Success! The configuration is valid.`
   for an empty directory, so the step always passes. The `aws/ecs-service`
   module is used by about 10 application repositories (backend, frontend,
   admin, devhub, identity, mcp and others). It has the largest blast radius
   of all our modules, and it has no validate, lint or test step.
2. **Module lock files are ignored.** `.gitignore` has
   `modules/**/.terraform.lock.hcl`. Modules use open constraints (for example
   `aws >= 6.37.0`), so CI tests against the newest provider on each run. A
   local run uses the lock file that `init` wrote the first time. An old local
   lock file makes tests fail for a reason that is not in the code. We saw
   this: `modules/waf` failed with `The provider hashicorp/aws does not
   support resource type "aws_wafv2_web_acl_rule"` because a local lock file
   pinned `aws 5.94.1`. `terraform init -upgrade` fixed it.
3. **Terraform versions do not agree.** `.tool-versions` has `1.12.2`, the
   deploy workflows use `1.13.4`, `terraform-modules` CI uses `1.12`, and the
   README says `v1.10`. A test can pass on one version and fail on another.
4. **17 of 20 local modules have no tests.** Only `waf`, `api-gateway` and
   `elasticache` have tests. `modules/elasticache-redis` has no `.tf` files
   and can be deleted.
5. **There is no security or policy scan.** No Checkov, Trivy, tfsec or OPA
   step exists in either repository.
6. **Environment roots have no tests.** Each environment has its own copy of
   `common/*.tf`, with deliberate differences (for example, WAF rules in
   `count` mode in production and `block` mode in development). Only the
   plan comment on the PR shows these differences, and a person must read it.

## Options considered

| Option | What it does | Decision |
|--------|--------------|----------|
| `terraform test` with `mock_provider` | HCL tests. Plans a module with fake provider responses. No credentials. | **Use.** It is native, needs no new language, and we already use it. |
| `terraform test` with `command = apply` against AWS | Creates real resources, then destroys them. | Do not use. It is slow, costs money, and needs a test account. Development apply gives this signal already. |
| Terratest (Go) | Go tests that apply real infrastructure. | Do not use. It adds a new language and has the same cost as a real apply. |
| Trivy (`trivy config`) | Static scan for insecure settings, for example public S3 buckets or no encryption. | **Use.** It is one binary and it reads HCL directly. Trivy replaces tfsec. |
| Checkov | Static scan, similar to Trivy. | Alternative to Trivy. Do not run both. |
| OPA / Conftest on plan JSON | Policy rules on the real environment plan. | Later. See "Phase 3". |

## Approach

We use four layers. Each layer catches a different class of error. The
fast layers run first.

```
  fast, local, no credentials                     slow, real AWS
  +------------+  +--------------+  +---------+  +------------------------+
  | fmt        |  | module tests |  | Trivy   |  | plan, dev apply,       |
  | validate   |->| (mock, plan) |->| scan    |->| staging apply, e2e     |
  | tflint     |  |              |  |         |  | (exists today)         |
  +------------+  +--------------+  +---------+  +------------------------+
```

### Layer 1: static checks

These exist. Fix gaps 1 to 3 so that the results are true.

### Layer 2: module tests

Every module in `modules/` and in `terraform-modules/aws/` gets a `tests/`
directory. `scripts/run-terraform-tests` finds these files automatically, and
CI runs the script in the `lint` job.

**Test these:**

- Each `validation` block. Write one run that gives a bad value and uses
  `expect_failures`.
- Each conditional resource (`count = var.x ? 1 : 0`). Write one run for each
  branch and assert on `length(resource.name)`.
- Each `for_each` and `dynamic` block that builds resources from a caller's
  input. Assert on the keys and on the important attributes.
- Derived values: names, ARNs that the module builds, priorities, and
  conditional attributes (`var.x ? var.y : null`).
- Settings that protect data or access: encryption, `deletion_protection`,
  backup retention, public access, WAF actions.

**Do not test these:**

- A variable that passes straight to one resource attribute with no logic.
  The test would only repeat the code.
- AWS behaviour. A mock provider does not know if AWS accepts a value.
  Development apply catches that.
- Values that are unknown at plan time. See "Pitfalls".

**Rule for new work:** a PR that changes the behaviour of a module adds or
changes a test for that behaviour. Write the test first and see it fail.

### Layer 3: security scan

Add `trivy config` to pre-commit and to the CI `lint` job. Run it on
`modules/`, `environments/` and `terraform-modules/aws/`. Start with
`--severity HIGH,CRITICAL` and a `.trivyignore` file for accepted findings.
Each entry in `.trivyignore` has a comment that gives the reason.

### Layer 4: plan and apply

This exists and does not change: plan comment on the PR, apply to
development, apply to staging on merge, e2e tests, then production with
approval.

## How to write a module test

Put the file in `modules/<module>/tests/<behaviour>.tftest.hcl`. Use one file
for one behaviour or one resource. The name of each `run` block says what
must be true.

`modules/elasticache/tests/replication_group.tftest.hcl` is a complete
example. This is the pattern:

```hcl
mock_provider "aws" {}

# Shared inputs for all runs in this file. A run block can override them.
variables {
  replication_group_id = "test-redis"
  # ... other required variables
}

run "creates_subnet_group_when_no_name_is_given" {
  command = plan

  assert {
    condition     = length(aws_elasticache_subnet_group.this) == 1
    error_message = "A subnet group must be created when subnet_group_name is null."
  }
}

run "rejects_unknown_engine" {
  command = plan

  variables {
    engine = "memcached"
  }

  expect_failures = [
    var.engine,
  ]
}
```

To see that a test can fail, change the module code by hand (for example,
remove a condition), run the test, see it fail, then revert the change.

### Pitfalls

- **Use `mock_provider`, not fake credentials.** A real provider with fake
  credentials fails when the module has a `data` source. `mock_provider` gives
  fake values for all `data` sources and computed attributes.
- **Unknown values at plan time.** A computed attribute is unknown in a plan.
  This includes an attribute that is Optional and Computed when the module
  sets it to `null`. An assert on an unknown value fails with `Unknown
  condition value`. Assert on an input, a local, or an attribute that is not
  computed. You can also use `override_resource` with
  `override_during = plan` to give the attribute a fixed value.
- **Mock data sources give random strings.** For example,
  `aws_iam_policy_document.json` is a random string, so `jsondecode` fails.
  Use `override_data` to give a real value:

  ```hcl
  override_data {
    target = data.aws_iam_policy_document.this
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
  ```

- **The provider still validates arguments.** A mock provider does not call
  AWS, but it runs the provider's own argument checks. For example, the AWS
  provider rejects an ElastiCache `auth_token` that is shorter than 16
  characters. Give valid test values.
- **Sensitive values.** A condition that uses a sensitive value is itself
  sensitive. Wrap the result in `nonsensitive(...)`.
- **Old lock files.** If a test fails with `does not support resource type`,
  run `terraform -chdir=modules/<module> init -upgrade`.

## How to run

```shell
# All module tests in this repository
scripts/run-terraform-tests

# One module
terraform -chdir=modules/elasticache init -backend=false
terraform -chdir=modules/elasticache test

# One file, with detail
terraform -chdir=modules/waf test -filter=tests/ip_sets.tftest.hcl -verbose
```

Timings on a laptop: `modules/elasticache` takes about 1 second for 6 runs.
`modules/waf` takes about 80 seconds for 30 runs. The full suite takes about
90 seconds.

## Rollout

### Phase 1: fix the checks we have

1. `terraform-modules`: fix the CI loop so that it runs `init`, `validate`
   and `test` in each `aws/*/` directory. Add `tflint`.
2. Use one Terraform version. Set it in `.tool-versions` in both
   repositories, and make the workflows read it. Update the README.
3. Decide on module lock files. The simple fix is to keep them ignored and
   run `init -upgrade` in `scripts/run-terraform-tests`. Then local runs and
   CI use the same provider version.
4. Delete `modules/elasticache-redis`.
5. Change `modules/api-gateway/tests/cache_defaults.tftest.hcl` to use
   `mock_provider`.

### Phase 2: tests for the modules with the most logic

The order below uses blast radius and the quantity of logic (conditionals,
`for_each`, `dynamic` blocks and validations) in each module.

| Order | Module | Why |
|-------|--------|-----|
| 1 | `terraform-modules/aws/ecs-service` | Used by about 10 application repositories. 6 validation rules with no tests. |
| 2 | `cognito` | 25 conditionals, 17 `for_each`, 16 `dynamic` blocks. Controls user access. |
| 3 | `application-load-balancer` | 13 `for_each`, 7 `dynamic` blocks. Routes all traffic. |
| 4 | `cloudfront` | 15 `for_each`, 13 `dynamic` blocks. Cache and origin rules. |
| 5 | `opensearch` | 11 conditionals, 5 data sources. Holds search data. |
| 6 | `rds_cluster`, `rds` | Hold the tariff data. Test encryption, deletion protection and backups. |
| 7 | `aws-notify-slack`, `ses` | Conditional resources with `count`. |
| - | `acm`, `secret`, `ecr`, `cloudwatch*`, `firehose_delivery`, `lambda`, `security-group` | Little logic. Add tests when a PR changes them. |

`elasticache` has tests from this change.

### Phase 3: later

- Add Trivy (Layer 3).
- Add a check on the development plan JSON (`tfplan.json`) that fails when
  the plan deletes or replaces a stateful resource (RDS, ElastiCache,
  OpenSearch, S3) without the `high-risk` label. The plan JSON exists in CI
  already.
