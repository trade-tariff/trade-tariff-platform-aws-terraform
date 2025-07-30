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
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::terraform-state-${var.environment}-${local.account_id}",
          "arn:aws:s3:::terraform-state-${var.environment}-${local.account_id}/*"
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
          module.fpo_search_configuration.secret_arn,
        ]
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

resource "aws_iam_policy" "ci_reporting_policy" {
  name        = "ci-reporting-policy"
  description = "Policy for Github Actions to enable read/write access to reporting bucket for deploying the reporting app https://github.com/trade-tariff/trade-tariff-reporting"

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

resource "aws_iam_policy" "ci_appendix5a_persistence_readwrite_policy" {
  name        = "ci-appendix5a-persistence-readwrite-policy"
  description = "Policy for Github Actions to enable read/write access to Appendix5a persistence bucket"

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
          "arn:aws:s3:::${aws_s3_bucket.this["persistence"].id}/config/chief_cds_guidance.json",
          "arn:aws:s3:::${aws_s3_bucket.this["persistence"].id}/config/cds_guidance.json"
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

resource "aws_iam_policy" "ci_tech_docs_persistence_readwrite_policy" {
  name        = "ci-tech-docs-persistence-readwrite-policy"
  description = "Policy for Github Actions to enable read/write access to Tech Docs bucket"

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
          "arn:aws:s3:::${aws_s3_bucket.this["tech-docs"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["tech-docs"].id}/*"
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

resource "aws_iam_policy" "ci_fpo_models_policy" {
  name        = "ci-fpo-models-policy"
  description = "Policy for Github Actions to enable read access to FPO models bucket"

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
    ]
  })
}

resource "aws_iam_policy" "ci_e2e_testing_policy" {
  name        = "ci-e2e-testing-policy"
  description = "Policy for GithubActions to enable E2E testing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowS3OperationsForEmailAndLock"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:HeadObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this["ses-inbound"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["ses-inbound"].id}/*",
        ]
        Effect = "Allow"
      },
      {
        Sid = "AllowKMSFull"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = ["*"]
        Effect   = "Allow"
      },
      {
        Sid = "AllowCognitoUserManagement"
        Action = [
          "cognito-idp:ListUserPools",
          "cognito-idp:AdminListUsers",
          "cognito-idp:AdminDeleteUser"
        ]
        Resource = [
          module.identity_cognito.user_pool_arn,
        ]
        Effect = "Allow"
      }
    ]
  })
}
