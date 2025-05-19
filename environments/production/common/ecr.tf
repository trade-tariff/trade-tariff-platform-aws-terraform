locals {
  ecr_actions = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:BatchGetImage",
    "ecr:CompleteLayerUpload",
    "ecr:DescribeImages",
    "ecr:DescribeRepositories",
    "ecr:GetDownloadUrlForLayer",
    "ecr:InitiateLayerUpload",
    "ecr:ListImages",
    "ecr:PutImage",
    "ecr:UploadLayerPart",
  ]
}

data "aws_iam_policy_document" "ecr_policy_document" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_ids["development"]}:root",
        "arn:aws:iam::${var.account_ids["staging"]}:root",
        "arn:aws:iam::${var.account_ids["production"]}:root",
        "arn:aws:iam::${var.account_ids["development"]}:role/GithubActions-Serverless-Lambda-Role",
        "arn:aws:iam::${var.account_ids["staging"]}:role/GithubActions-Serverless-Lambda-Role",
        "arn:aws:iam::${var.account_ids["production"]}:role/GithubActions-Serverless-Lambda-Role",
      ]
    }

    actions = local.ecr_actions
  }

  statement {
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }

    actions = local.ecr_actions

    condition {
      test     = "StringLike"
      variable = "aws:sourceArn"
      values = [
        "arn:aws:lambda:eu-west-2:${var.account_ids["development"]}:function:*",
        "arn:aws:lambda:eu-west-2:${var.account_ids["staging"]}:function:*",
        "arn:aws:lambda:eu-west-2:${var.account_ids["production"]}:function:*",
      ]
    }
  }
}

module "ecr" {
  source      = "../../../modules/ecr/"
  environment = var.environment
}

resource "aws_ssm_parameter" "ecr_url" {
  for_each    = module.ecr.repository_urls
  name        = "/${var.environment}/${replace(upper(each.key), "-", "_")}_ECR_URL"
  description = "${title(each.key)} ECR repository URL."
  type        = "SecureString"
  value       = each.value
}

resource "aws_ecr_repository_policy" "ecr_allow_staging_and_development" {
  for_each   = module.ecr.repository_urls
  repository = "tariff-${each.key}-${var.environment}"
  policy     = data.aws_iam_policy_document.ecr_policy_document.json
}
