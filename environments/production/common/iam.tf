resource "aws_iam_user" "reporting_ci" {
  name = "reporting-ci"
}

resource "aws_iam_user_policy_attachment" "reporting_ci_attachment" {
  user       = aws_iam_user.reporting_ci.name
  policy_arn = aws_iam_policy.ci_reporting_policy.arn
}

resource "aws_iam_policy" "ci_reporting_policy" {
  name        = "ci-reporting-policy"
  description = "Policy for CircleCI context to enable read/write access to reporting bucket for deploying the reporting app https://github.com/trade-tariff/trade-tariff-reporting"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],

        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this["reporting"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["reporting"].id}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = [
          aws_kms_alias.s3_kms_alias.target_key_arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:CreateInvalidation",
        ],
        Resource = [
          "arn:aws:cloudfront::${local.account_id}:distribution/${module.reporting_cdn.aws_cloudfront_distribution_id}"
        ]
      }
    ]
  })
}

resource "aws_iam_user" "serverless_lambda_ci" {
  name = "serverless-lambda-ci"
}

resource "aws_iam_user_policy_attachment" "serverless_lambda_ci_attachment" {
  user       = aws_iam_user.serverless_lambda_ci.name
  policy_arn = aws_iam_policy.ci_lambda_deployment_policy.arn
}

resource "aws_iam_policy" "ci_lambda_deployment_policy" {
  name        = "ci-lambda-deployment-policy"
  description = "Policy for CircleCI deployments of serverless applications"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this["lambda-deployment"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["lambda-deployment"].id}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["cloudformation:*"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["lambda:*"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:TagRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:TagResource",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["events:*"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = [
          aws_kms_alias.s3_kms_alias.target_key_arn
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "breakglass_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::036807458659:user/trade-tariff-breakglass"]
    }
  }
}

resource "aws_iam_role" "breakglass" {
  name               = "breakglass-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.breakglass_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "breakglass_role_policy_attachment" {
  role       = aws_iam_role.breakglass.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_user" "appendix5a_ci" {
  name = "appendix5a-ci"
}

resource "aws_iam_user_policy_attachment" "appendix5a_ci_attachment" {
  user       = aws_iam_user.appendix5a_ci.name
  policy_arn = aws_iam_policy.ci_appendix5a_peristence_readwrite_policy.arn
}

resource "aws_iam_policy" "ci_appendix5a_peristence_readwrite_policy" {
  name        = "ci-appendix5a-persistence-readwrite-policy"
  description = "Policy for CircleCI context to enable read/write access to Appendix5a persistence bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this["persistence"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["persistence"].id}/config/chief_cds_guidance.json"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = [
          aws_kms_alias.s3_kms_alias.target_key_arn
        ]
      }
    ]
  })
}
