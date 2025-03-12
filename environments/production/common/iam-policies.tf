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
