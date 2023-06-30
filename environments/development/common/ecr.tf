module "ecr" {
  source      = "../../common/ecr/"
  tags        = var.tags
  environment = var.environment
}

resource "aws_ssm_parameter" "ecr_url" {
  for_each    = module.ecr.repository_urls
  name        = "/${var.environment}/${replace(upper(each.key), "-", "_")}_ECR_URL"
  description = "${title(each.key)} ECR repository URL for ${var.environment}."
  type        = "SecureString"
  value       = each.value
  tags        = var.tags
}
