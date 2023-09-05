resource "aws_iam_user" "serverless-lambda-ci" {
  name = "serverless-lambda-ci"
}

resource "aws_iam_user_policy_attachment" "serverless-lambda-ci-attachment" {
  user       = aws_iam_user.serverless-lambda-ci.name
  policy_arn = aws_iam_policy.ci-lambda-deployment-policy.arn
}

resource "aws_iam_policy" "ci-lambda-deployment-policy" {
  name        = "ci-lambda-deployment-policy"
  description = "Policy for CircleCI deployments of serverless applications"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this["lambda-deployment"].id}",
          "arn:aws:s3:::${aws_s3_bucket.this["lambda-deployment"].id}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResource",
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:ValidateTemplate"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:PassRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "events:PutRule",
          "events:PutTargets"
        ],
        Resource = "*"
      }
    ]
  })
}
