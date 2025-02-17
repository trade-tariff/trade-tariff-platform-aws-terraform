resource "aws_ssm_parameter" "ecr_url" {
  for_each    = toset(local.applications)
  name        = "/${var.environment}/${replace(upper(each.key), "-", "_")}_ECR_URL"
  description = "${title(each.key)} ECR repository URL."
  type        = "SecureString"
  value       = "${var.account_ids["production"]}.dkr.ecr.${var.region}.amazonaws.com/tariff-${each.key}-production"
}
