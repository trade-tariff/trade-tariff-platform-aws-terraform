resource "aws_iam_policy" "ci_terraform_policy" {
  name        = "ci-terraform-policy"
  description = "Policy for Terraform to manage resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "acm:*",
          "application-autoscaling:*",
          "autoscaling:*",
          "cloudformation:*",
          "cloudfront:*",
          "cloudwatch:*",
          "cognito-idp:*",
          "dynamodb:*",
          "ec2:*",
          "ecr:*",
          "ecs:*",
          "elasticache:*",
          "elasticloadbalancing:*",
          "es:*",
          "events:*",
          "iam:*",
          "kms:*",
          "lambda:*",
          "logs:*",
          "rds:*",
          "route53:*",
          "s3:*",
          "secretsmanager:*",
          "ses:*",
          "sns:*",
          "sqs:*",
          "ssm:*",
          "sts:*",
          "servicediscovery:*",
          "wafv2:*"
        ],
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:RequestedRegion" : ["eu-west-2", "us-east-1"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ci_ecs_deployment_policy" {
  name        = "ci-ecs-deployment-policy"
  description = "Policy for ECS deployments"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "application-autoscaling:*",
          "cloudwatch:*",
          "cognito-idp:DescribeUserPool",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ecr:*",
          "ecs:*",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:CreateRole",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:DetachRolePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListGroups",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions",
          "iam:ListRolePolicies",
          "iam:ListRoles",
          "iam:ListUsers",
          "iam:PassRole",
          "iam:UpdatePolicy",
          "kms:*",
          "logs:*",
          "secretsmanager:*",
          "servicediscovery:*",
          "sts:AssumeRoleWithWebIdentity",
        ],
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:RequestedRegion" : ["eu-west-2", "us-east-1"]
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::terraform-state-${var.environment}-${local.account_id}",
          "arn:aws:s3:::terraform-state-${var.environment}-${local.account_id}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          "arn:aws:dynamodb:${var.region}:${local.account_id}:table/*-lock-*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:BatchGetSecretValue",
          "secretsmanager:ListSecrets",
        ],
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:*configuration*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ci_api_docs_policy" {
  name        = "ci-api-docs-policy"
  description = "Policy for API docs deployments"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:*",
          "sts:AssumeRoleWithWebIdentity",
        ],
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:RequestedRegion" : ["eu-west-2", "us-east-1"]
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::trade-tariff-api-docs-${local.account_id}",
          "arn:aws:s3:::trade-tariff-api-docs-${local.account_id}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:ListDistributions",
          "cloudfront:CreateInvalidation",
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ci_lambda_deployment_policy" {
  name        = "ci-lambda-deployment-policy"
  description = "Policy for GithubActions deployments of serverless applications"

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
          "arn:aws:s3:::${aws_s3_bucket.this["lambda-deployment"].id}/*",
          "arn:aws:s3:::${aws_s3_bucket.this["database-backups"].id}",
          "arn:aws:s3:::trade-tariff-models-382373577178",
          "arn:aws:s3:::trade-tariff-models-382373577178/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = [
          # Production S3 KMS key
          "arn:aws:kms:eu-west-2:382373577178:key/7fc9fd19-e970-4877-9b56-3869a02c7b85"
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
          "iam:CreateServiceLinkedRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:TagRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DeleteLogGroup",
          "logs:TagResource",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms"
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
          aws_kms_alias.s3_kms_alias.target_key_arn,
          aws_kms_alias.secretsmanager_kms_alias.target_key_arn,
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:ListSecrets",
          "secretsmanager:ListSecretVersionIds",
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
        ],
        Resource = [
          module.fpo_search_sentry_dsn.secret_arn,
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = [for v in aws_ssm_parameter.ecr_url : v.arn]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ],
        Resource = [
          "arn:aws:ecr:*:*:repository/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "apigateway:*"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "acm:ListCertificates",
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
        ],
        Resource = [data.aws_route53_zone.this.arn]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables"
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables"
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:*",
        ],
        Resource = ["*"]
      },
    ]
  })
}
