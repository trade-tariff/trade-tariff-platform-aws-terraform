resource "aws_iam_role" "reporting_ci_role" {
  name = "GithubActions-Reporting-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/trade-tariff-reporting:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "reporting_ci_policy_attachment" {
  role       = aws_iam_role.reporting_ci_role.name
  policy_arn = aws_iam_policy.ci_reporting_policy.arn
}

resource "aws_iam_role" "serverless_lambda_ci_role" {
  name = "GithubActions-Serverless-Lambda-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/trade-tariff-lambdas-fpo-search:*",
              "repo:trade-tariff/trade-tariff-lambdas-fpo-model-garbage-collection:*",
              "repo:trade-tariff/trade-tariff-lambdas-electronic-tariff-file-rotations:*",
              "repo:trade-tariff/trade-tariff-lambdas-database-backups:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "serverless_lambda_ci_policy_attachment" {
  role       = aws_iam_role.serverless_lambda_ci_role.name
  policy_arn = aws_iam_policy.ci_lambda_deployment_policy.arn
}

resource "aws_iam_role" "appendix5a_ci_role" {
  name = "GithubActions-Appendix5a-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/process-appendix-5a:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "appendix5a_ci_policy_attachment" {
  role       = aws_iam_role.appendix5a_ci_role.name
  policy_arn = aws_iam_policy.ci_appendix5a_persistence_readwrite_policy.arn
}

resource "aws_iam_role" "tech_docs_ci_role" {
  name = "GithubActions-Tech-Docs-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/trade-tariff-tech-docs:*" # There is no ci policy for this repo, using github actions
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tech_docs_ci_policy_attachment" {
  role       = aws_iam_role.tech_docs_ci_role.name
  policy_arn = aws_iam_policy.ci_tech_docs_persistence_readwrite_policy.arn
}

resource "aws_iam_role" "fpo_models_ci_role" {
  name = "GithubActions-FPO-Models-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/trade-tariff-lambdas-fpo-search:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fpo_models_ci_policy_attachment" {
  role       = aws_iam_role.fpo_models_ci_role.name
  policy_arn = aws_iam_policy.ci_fpo_models_policy.arn
}

resource "aws_iam_role" "ci_terraform_role" {
  name = "GithubActions-Terraform-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/trade-tariff-platform-aws-terraform:*",
              "repo:trade-tariff/trade-tariff-platform-terraform-aws-accounts:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_terraform_ci_policy_attachment" {
  role       = aws_iam_role.ci_terraform_role.name
  policy_arn = aws_iam_policy.ci_terraform_policy.arn
}

resource "aws_iam_role" "ci_ecs_deployments_role" {
  name = "GithubActions-ECS-Deployments-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/identity:*",
              "repo:trade-tariff/trade-tariff-admin:*",
              "repo:trade-tariff/trade-tariff-api-docs:*",
              "repo:trade-tariff/trade-tariff-backend:*",
              "repo:trade-tariff/trade-tariff-commodi-tea:*",
              "repo:trade-tariff/trade-tariff-dev-hub:*",
              "repo:trade-tariff/trade-tariff-frontend:*",
              "repo:trade-tariff/trade-tariff-tools:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_deployments_ci_policy_attachment" {
  role       = aws_iam_role.ci_ecs_deployments_role.name
  policy_arn = aws_iam_policy.ci_ecs_deployment_policy.arn
}

resource "aws_iam_role" "ci_api_docs_role" {
  name = "GithubActions-API-Docs-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/trade-tariff-api-docs:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_docs_ci_policy_attachment" {
  role       = aws_iam_role.ci_api_docs_role.name
  policy_arn = aws_iam_policy.ci_api_docs_policy.arn
}

resource "aws_iam_role" "e2e_testing_ci_role" {
  name = "GithubActions-E2E-Testing-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${aws_iam_openid_connect_provider.github_oidc.url}:sub" = [
              "repo:trade-tariff/identity:*",
              "repo:trade-tariff/trade-tariff-admin:*",
              "repo:trade-tariff/trade-tariff-backend:*",
              "repo:trade-tariff/trade-tariff-commodi-tea:*",
              "repo:trade-tariff/trade-tariff-dev-hub:*",
              "repo:trade-tariff/trade-tariff-e2e-tests:*",
              "repo:trade-tariff/trade-tariff-fpo-dev-hub-e2e:*",
              "repo:trade-tariff/trade-tariff-frontend:*",
              "repo:trade-tariff/trade-tariff-platform-aws-terraform:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "e2e_testing_ci_policy_attachment" {
  role       = aws_iam_role.e2e_testing_ci_role.name
  policy_arn = aws_iam_policy.ci_e2e_testing_policy.arn
}
