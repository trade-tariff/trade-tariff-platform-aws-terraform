resource "aws_iam_role" "reporting_ci_role" {
  name = "CircleCI-Reporting-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id
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
  name = "CircleCI-Serverless-Lambda-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id

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
  name = "CircleCI-Appendix5a-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id
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
  name = "CircleCI-Tech-Docs-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id
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

resource "aws_iam_role" "status_checks_ci_role" {
  name = "CircleCI-Status-Checks-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "status_checks_ci_policy_attachment" {
  role       = aws_iam_role.status_checks_ci_role.name
  policy_arn = aws_iam_policy.ci_status_checks_persistence_readwrite_policy.arn
}

resource "aws_iam_role" "fpo_models_ci_role" {
  name = "CircleCI-FPO-Models-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fpo_models_ci_policy_attachment" {
  role       = aws_iam_role.fpo_models_ci_role.name
  policy_arn = aws_iam_policy.ci_fpo_models_secrets_policy.arn
}

resource "aws_iam_role" "terraform_role" {
  name = "CircleCi_Terraform-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.circleci_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.circleci_oidc.url}:aud" = var.circleci_organisation_id
          }
          # StringLike = {
          #   "${aws_iam_openid_connect_provider.circleci_oidc.url}:sub" = [
          #     for project_id in var.allowed_circleci_projects : "org/${var.circleci_organisation_id}/project/${project_id/user/*}"
          #   ]
          # }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_terraform_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.ci_terraform_policy.arn
}
