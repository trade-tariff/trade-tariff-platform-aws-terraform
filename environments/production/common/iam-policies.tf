resource "aws_iam_policy" "ci_terraform_policy" {
  name        = "ci-terraform-policy"
  description = "Policy for Terraform to manage resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "dynamodb:*",
          "s3:*",
          "rds:*",
          "cloudfront:*",
          "wafv2:*",
          "cognito-idp:*",
          "sns:*",
          "route53:*",
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
