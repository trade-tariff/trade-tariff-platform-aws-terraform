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
          "apigateway:*",
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
          "firehose:*",
          "iam:*",
          "kms:*",
          "lambda:*",
          "logs:*",
          "rds:*",
          "route53:*",
          "s3:*",
          "secretsmanager:*",
          "servicediscovery:*",
          "ses:*",
          "sns:*",
          "sqs:*",
          "ssm:*",
          "sts:*",
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
        Sid    = "ECSDeployment",
        Effect = "Allow",
        Action = [
          # Application Autoscaling - ECS service autoscaling targets and policies
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:DeregisterScalableTarget",
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:DescribeScalingActivities",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:DescribeScheduledActions",
          "application-autoscaling:ListTagsForResource",
          "application-autoscaling:PutScalingPolicy",
          "application-autoscaling:RegisterScalableTarget",
          # CloudWatch - alarms for service health, dashboards (backend)
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DeleteDashboards",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetDashboard",
          "cloudwatch:ListDashboards",
          "cloudwatch:ListTagsForResource",
          "cloudwatch:PutDashboard",
          "cloudwatch:PutMetricAlarm",
          # Cognito - identity service reads user pool config
          "cognito-idp:DescribeUserPool",
          # EC2 - read-only data sources for VPC, subnets, security groups
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          # ECR - docker build, push, tag images
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          # ECS - task definitions, services, exec
          "ecs:CreateService",
          "ecs:DeleteService",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ExecuteCommand",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:TagResource",
          "ecs:UpdateService",
          # ELB - read-only data sources for target groups
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          # EventBridge - backend scheduled tasks (db backup, replication)
          "events:DeleteRule",
          "events:DescribeRule",
          "events:ListTagsForResource",
          "events:ListTargetsByRule",
          "events:PutRule",
          "events:PutTargets",
          "events:RemoveTargets",
          # IAM - task/execution roles and policies managed by ECS module
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:CreateRole",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions",
          "iam:ListRolePolicies",
          "iam:PutRolePolicy",
          "iam:TagRole",
          "iam:UpdateAssumeRolePolicy",
          # KMS - decrypt secrets, terraform state encryption
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          # Logs - log groups for ECS containers
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:PutRetentionPolicy",
          # Secrets Manager - read secrets for task environment variables
          "secretsmanager:BatchGetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          # Service Discovery - Cloud Map for internal service DNS
          "servicediscovery:CreateService",
          "servicediscovery:DeleteService",
          "servicediscovery:GetNamespace",
          "servicediscovery:GetService",
          "servicediscovery:ListNamespaces",
          "servicediscovery:ListServices",
          "servicediscovery:ListTagsForResource",
          "servicediscovery:UpdateService",
          # SNS - read-only for alarm notification topics
          "sns:GetTopicAttributes",
          "sns:ListTagsForResource",
          "sns:ListTopics",
          # STS - caller identity data source
          "sts:GetCallerIdentity",
        ],
        Resource  = "*",
        Condition = { "StringEquals" = { "aws:RequestedRegion" = ["eu-west-2", "us-east-1"] } }
      },
      {
        Sid       = "IAMPassRole",
        Effect    = "Allow",
        Action    = ["iam:PassRole"],
        Resource  = ["arn:aws:iam::${local.account_id}:role/*"],
        Condition = { "StringEquals" = { "aws:RequestedRegion" = ["eu-west-2", "us-east-1"] } }
      },
      {
        Sid    = "TerraformState",
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          "arn:aws:s3:::terraform-state-${var.environment}-${local.account_id}",
          "arn:aws:s3:::terraform-state-${var.environment}-${local.account_id}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ci_terraform_teams_policy" {
  name        = "ci-terraform-teams-policy"
  description = "Policy for Terraform to store state as part of the teams repo run"

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
            "aws:RequestedRegion" : ["eu-west-2"]
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
        Sid    = "ServerlessDeployment",
        Effect = "Allow",
        Action = [
          # ACM - serverless-domain-manager looks up certificates
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          # API Gateway - fpo-search REST API, custom domains, usage plans
          "apigateway:DELETE",
          "apigateway:GET",
          "apigateway:PATCH",
          "apigateway:POST",
          "apigateway:PUT",
          # CloudFormation - serverless framework manages all resources via CF
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeChangeSet",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStacks",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:GetTemplate",
          "cloudformation:ListStackResources",
          "cloudformation:UpdateStack",
          "cloudformation:ValidateTemplate",
          # CloudWatch - fpo-search error and duration alarms
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm",
          # EC2 - read-only data sources for VPC networking
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          # EventBridge - cron schedules for ETF rotations and GC lambdas
          "events:DeleteRule",
          "events:DescribeRule",
          "events:ListRules",
          "events:ListTagsForResource",
          "events:ListTargetsByRule",
          "events:PutRule",
          "events:PutTargets",
          "events:RemoveTargets",
          # Lambda - function lifecycle and provisioned concurrency
          "lambda:AddPermission",
          "lambda:CreateAlias",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetAlias",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:GetPolicy",
          "lambda:GetProvisionedConcurrencyConfig",
          "lambda:ListAliases",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
          "lambda:PutProvisionedConcurrencyConfig",
          "lambda:DeleteProvisionedConcurrencyConfig",
          "lambda:RemovePermission",
          "lambda:TagResource",
          "lambda:UpdateAlias",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          # Logs - log groups with retention policies
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogGroup",
          "logs:DeleteRetentionPolicy",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:ListTagsForResource",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:UntagResource",
          # Route53 - custom domain DNS records for fpo-search
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          # STS - caller identity
          "sts:GetCallerIdentity",
        ],
        Resource = "*",
        Condition = {
          "StringEquals" = { "aws:RequestedRegion" = ["eu-west-2", "us-east-1"] }
        }
      },
      {
        Sid      = "Route53ChangeRecords",
        Effect   = "Allow",
        Action   = ["route53:ChangeResourceRecordSets"],
        Resource = [data.aws_route53_zone.this.arn]
      },
      {
        Sid    = "IAMRoleManagement",
        Effect = "Allow",
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:CreateServiceLinkedRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:TagRole",
        ],
        Resource = ["arn:aws:iam::${local.account_id}:role/*"],
        Condition = {
          "StringEquals" = { "aws:RequestedRegion" = ["eu-west-2", "us-east-1"] }
        }
      },
      {
        Sid    = "S3DeploymentBuckets",
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
          aws_s3_bucket.deployment-bucket-us-east-1.arn,
          "${aws_s3_bucket.deployment-bucket-us-east-1.arn}/*",
          "arn:aws:s3:::trade-tariff-models-382373577178",
          "arn:aws:s3:::trade-tariff-models-382373577178/*",
        ]
      },
      {
        Sid    = "ECRImages",
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
        Resource = ["arn:aws:ecr:*:*:repository/*"]
      },
      {
        Sid      = "ECRAuth",
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Sid    = "KMSDecrypt",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ],
        Resource = [
          aws_kms_alias.s3_kms_alias.target_key_arn,
          aws_kms_alias.secretsmanager_kms_alias.target_key_arn,
          # Production S3 KMS key (fpo-search reads models from production bucket)
          "arn:aws:kms:eu-west-2:382373577178:key/7fc9fd19-e970-4877-9b56-3869a02c7b85",
        ]
      },
      {
        Sid    = "SecretsManagerList",
        Effect = "Allow",
        Action = [
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets",
        ],
        Resource = ["*"]
      },
      {
        Sid    = "SecretsManagerRead",
        Effect = "Allow",
        Action = ["secretsmanager:GetSecretValue"],
        Resource = [
          module.fpo_search_configuration.secret_arn,
        ]
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

resource "aws_iam_policy" "ci_etf_policy" {
  name        = "ci-etf-policy"
  description = "Policy for Github Actions to write the Electronic Tariff File contents and send emails"

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
          aws_kms_alias.s3_kms_alias.target_key_arn,
          aws_kms_key.secretsmanager_kms_key.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = [module.etf_configuration.secret_arn]
      }
    ]
  })
}

resource "aws_iam_policy" "ci_cds_downloader_file_policy" {
  name        = "ci-cds-downloader-policy"
  description = "Policy for Github Actions to enable read/write access to cds changes files"

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
          "arn:aws:s3:::${aws_s3_bucket.this["reporting"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["reporting"].id}/changes/uk/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = [
          aws_kms_alias.s3_kms_alias.target_key_arn,
          aws_kms_key.secretsmanager_kms_key.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = [module.download_cds_files_configuration.secret_arn]
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
          "arn:aws:s3:::${aws_s3_bucket.this["models"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["models"].id}/*"
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
    ]
  })
}

resource "aws_iam_policy" "ci_ecs_task_cleanup_policy" {
  name        = "ci-ecs-task-cleanup-policy"
  description = "Policy for Github Actions to list and deregister old ECS task definitions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
        ],
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:RequestedRegion" : ["eu-west-2"]
          }
        }
      }
    ]
  })
}
