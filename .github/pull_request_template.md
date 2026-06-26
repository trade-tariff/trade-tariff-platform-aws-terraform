## What:
<!-- A brief description of what this PR does -->

## Why:
<!-- The reasoning or context behind this change -->

## Ticket:
<!-- Link to the relevant Jira/ticket, or 'N/A' if not applicable -->

## Risk:
**Risk level:** 🟢 / 🟠 / 🔴 <!-- delete as appropriate -->

**Reason for rating:**
<!-- One or two sentences explaining your assessment, especially for Amber or Red -->

───────────────────────────────────────────────────

Rate the overall risk of deploying this change:

🟢 Green  – Low risk. Good to go, standard review applies.

🟠 Amber  – Medium risk. Socialise with the team before merging.

🔴 Red    – High risk. Requires explicit approval from Thor or Neil before merging.

───────────────────────────────────────────────────

🟢 GREEN – things that are typically low risk:
───────────────────────────────────────────────────
- Terraform formatting, variable renaming, or output changes with no resource recreation
- Adding or updating CloudWatch alarms or dashboards (read-only observability)
- Tagging changes with no resource replacement
- S3 lifecycle rule additions (non-destructive, time-delayed effect)
- Config/env var additions that are purely additive and have safe defaults
- New read-only IAM permissions or least-privilege tightening with no behaviour change
- Adding or updating documentation or README files

🟠 AMBER – things that need a team conversation first:
───────────────────────────────────────────────────
- Infrastructure changes that alter networking, security groups, or routing
- IAM permission additions or policy changes that grant new access
- Terraform changes that will cause a resource replacement (check plan output carefully)
- Changes to CI/CD pipeline steps or deployment order dependencies
- S3 bucket policy or access control changes
- Changes to RDS parameter groups, instance class, or storage configuration
- Adding or modifying WAF rules, CloudFront behaviours, or ALB listener rules
- Changes to auto-scaling configuration or capacity settings
- ECS task definition changes that alter CPU, memory, or environment variables

🔴 RED – requires explicit approval from Thor or Neil:
───────────────────────────────────────────────────
- Any change to production AWS infrastructure that cannot be easily rolled back (e.g. RDS parameter groups, KMS key policy, removal of resources)
- Secrets rotation or changes to how credentials are stored, scoped, or accessed
- Removal of any production resource (databases, queues, buckets, security groups)
- Changes to KMS keys, encryption configuration, or key policies
- Modifications to VPC topology, subnets, or internet gateway configuration
- Changes that affect cross-account access or assume-role trust relationships
- Significant architectural shifts (e.g. new service boundaries, queue/event topology changes)
