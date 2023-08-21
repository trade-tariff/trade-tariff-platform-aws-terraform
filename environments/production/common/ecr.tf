data "aws_iam_policy_document" "ecr_policy_document" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${lookup(var.account_ids, "development")}:root",
        "arn:aws:iam::${lookup(var.account_ids, "staging")}:root",
        "arn:aws:iam::${lookup(var.account_ids, "production")}:root",
      ]
    }
    actions = [
      "ecr:ListImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
}

module "ecr" {
  source      = "../../common/ecr/"
  tags        = var.tags
  environment = var.environment
}

resource "aws_ssm_parameter" "ecr_url" {
  for_each    = module.ecr.repository_urls
  name        = "/${replace(upper(each.key), "-", "_")}_ECR_URL"
  description = "${title(each.key)} ECR repository URL."
  type        = "SecureString"
  value       = each.value
  tags        = var.tags
}

resource "aws_ecr_repository_policy" "ecr_allow_staging_and_development" {
  for_each   = module.ecr.repository_urls
  repository = "tariff-${each.key}-${var.environment}"
  policy     = data.aws_iam_policy_document.ecr_policy_document.json
}
