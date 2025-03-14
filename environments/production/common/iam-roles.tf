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
      },
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
      },
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
              "repo:trade-tariff/trade-tariff-lambdas-status-checks:*",
              "repo:trade-tariff/trade-tariff-lambdas-fpo-search:*",
              "repo:trade-tariff/trade-tariff-lambdas-fpo-model-garbage-collection:*",
              "repo:trade-tariff/trade-tariff-lambdas-electronic-tariff-file-rotations:*",
              "repo:trade-tariff/trade-tariff-lambdas-uk-issues-mailer:*"
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
      },
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
      },
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
      },
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
              "repo:trade-tariff/trade-tariff-status:*"
            ]
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
      },
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
        }
      },
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
              "repo:trade-tariff/trade-tariff-duty-calculator:*",
              "repo:trade-tariff/trade-tariff-admin:*",
              "repo:trade-tariff/trade-tariff-frontend:*",
              "repo:trade-tariff/trade-tariff-backend:*",
              "repo:trade-tariff/trade-tariff-lambdas-fpo-search:*",
              "repo:trade-tariff/trade-tariff-team:*",
              "repo:trade-tariff/trade-tariff-platform-terraform-aws-accounts:*", # Check if this repo should be included
              "repo:trade-tariff/trade-tariff-api-docs:*",
              "repo:trade-tariff/trade-tariff-commodi-tea:*",
              "repo:trade-tariff/trade-tariff-lambdas-database-backups:*",
              "repo:trade-tariff/trade-tariff-dev-hub-frontend:*",
              "repo:trade-tariff/trade-tariff-dev-hub-backend:*",
              "repo:trade-tariff/trade-tariff-signon-builder:*",
              "repo:trade-tariff/trade-tariff-platform-dockerfiles:*",
              "repo:trade-tariff/trade-tariff-cloudwatch-synthetics-canaries:*",

            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_ci_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.ci_terraform_policy.arn
}

resource "aws_iam_role" "etf_ci_role" {
  name = "CircleCI-ETF-Role"

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
      },
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
              "repo:trade-tariff/fpo_categorisation_prototype_ui:*",
              "repo:trade-tariff/electronic-tariff-file:*",
            ]
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "etf_ci_policy_attachment" {
  role       = aws_iam_role.etf_ci_role.name
  policy_arn = aws_iam_policy.ci_etf_policy.arn

}

resource "aws_iam_role" "ci_downloader_file_ci_role" {
  name = "CircleCI-CDS-Downloader-File-Role"

  description = "Role for CircleCI to download files from S3"
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
      },
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
              "repo:trade-tariff/download-CDS-files:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_downloader_file_ci_policy_attachment" {
  role       = aws_iam_role.ci_downloader_file_ci_role.name
  policy_arn = aws_iam_policy.ci_cds_downloader_file_policy.arn

}

resource "aws_iam_role" "releases_user_role" {
  name = "CircleCI-Releases-Role"

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
      },
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
              "repo:trade-tariff/trade-tariff-releases:*",
              "repo:trade-tariff/trade-tariff-duty-calculator:*",
              "repo:trade-tariff/trade-tariff-admin:*",
              "repo:trade-tariff/trade-tariff-frontend:*",
              "repo:trade-tariff/trade-tariff-backend:*",
              "repo:trade-tariff/trade-tariff-commodi-tea:*",
              "repo:trade-tariff/trade-tariff-dev-hub-frontend:*",
              "repo:trade-tariff/trade-tariff-dev-hub-backend:*",
            ]
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "releases_user_policy_attachment" {
  role       = aws_iam_role.releases_user_role.name
  policy_arn = aws_iam_policy.release_policy.arn
}
