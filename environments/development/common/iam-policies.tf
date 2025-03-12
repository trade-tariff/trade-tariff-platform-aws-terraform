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
          "ecs:*",
          "ecr:*",
          "elasticache:*",
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
          "sqs:*",
          "ses:*",
          "sns:*",
          "ssm:*",
          "sts:*",
          "secretsmanager:*",
          "lambda:*",
          "kms:*",
          "cloudformation:*",
          "servicediscovery:*",
          "ecs:*",
          "ecr:*",
          "autoscaling:*",
          "cloudwatch:*"
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
