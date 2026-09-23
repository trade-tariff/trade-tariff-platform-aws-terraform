data "aws_iam_policy_document" "breakglass_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::036807458659:user/trade-tariff-breakglass"]
    }
  }
}

resource "aws_iam_role" "breakglass" {
  name               = "breakglass-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.breakglass_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "breakglass_role_policy_attachment" {
  role       = aws_iam_role.breakglass.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_s3_bucket_policy" "fpo_model_access" {
  bucket = aws_s3_bucket.this["models"].id

  policy = data.aws_iam_policy_document.fpo_model_access.json
}

data "aws_iam_policy_document" "fpo_model_access" {
  source_policy_documents = [data.aws_iam_policy_document.deny_insecure_transport["models"].json]

  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this["models"].id}",
      "arn:aws:s3:::${aws_s3_bucket.this["models"].id}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_ids["development"]}:role/fpo-model-garbage-collection-development-eu-west-2-lambdaRole",
        "arn:aws:iam::${var.account_ids["staging"]}:role/fpo-model-garbage-collection-staging-eu-west-2-lambdaRole",
        "arn:aws:iam::${var.account_ids["production"]}:role/fpo-model-garbage-collection-production-eu-west-2-lambdaRole",
        "arn:aws:iam::${var.account_ids["development"]}:role/GithubActions-FPO-Models-Role",
        "arn:aws:iam::${var.account_ids["staging"]}:role/GithubActions-FPO-Models-Role",
        "arn:aws:iam::${var.account_ids["production"]}:role/GithubActions-FPO-Models-Role",
        "arn:aws:iam::${var.account_ids["development"]}:role/GithubActions-Serverless-Lambda-Role",
        "arn:aws:iam::${var.account_ids["staging"]}:role/GithubActions-Serverless-Lambda-Role",
        "arn:aws:iam::${var.account_ids["production"]}:role/GithubActions-Serverless-Lambda-Role"

      ]
    }
  }
}
