module "ecr" {
  source      = "../../common/ecr/"
  tags        = var.tags
  environment = var.environment
}

resource "aws_ssm_parameter" "ecr_url" {
  name        = "/${var.environment}/ECR_URL"
  description = "ECR repository URL for ${var.environment}."
  type        = "SecureString"
  value       = module.ecr.repository_url
  tags        = var.tags
}
