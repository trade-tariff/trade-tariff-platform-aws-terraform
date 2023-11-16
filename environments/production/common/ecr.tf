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
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
  }

  statement {
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
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

    condition {
      test     = "StringLike"
      variable = "aws:sourceArn"
      values = [
        "arn:aws:lambda:eu-west-2:${lookup(var.account_ids, "development")}:function:*",
        "arn:aws:lambda:eu-west-2:${lookup(var.account_ids, "staging")}:function:*",
        "arn:aws:lambda:eu-west-2:${lookup(var.account_ids, "production")}:function:*",
      ]
    }
  }
}

module "ecr" {
  source      = "../../common/ecr/"
  tags        = var.tags
  environment = var.environment
}

resource "aws_ssm_parameter" "ecr_url" {
  for_each    = module.ecr.repository_urls
  name        = "/${var.environment}/${replace(upper(each.key), "-", "_")}_ECR_URL"
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
