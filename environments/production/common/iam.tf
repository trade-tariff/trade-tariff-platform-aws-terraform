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
        "arn:aws:iam::844815912454:role/fpo-model-garbage-collection-development-eu-west-2-lambdaRole",
        "arn:aws:iam::451934005581:role/fpo-model-garbage-collection-staging-eu-west-2-lambdaRole",
        "arn:aws:iam::382373577178:role/fpo-model-garbage-collection-production-eu-west-2-lambdaRole",
        "arn:aws:iam::844815912454:role/GithubActions-FPO-Models-Role",
        "arn:aws:iam::451934005581:role/GithubActions-FPO-Models-Role",
        "arn:aws:iam::382373577178:role/GithubActions-FPO-Models-Role",
        "arn:aws:iam::844815912454:role/GithubActions-Serverless-Lambda-Role",
        "arn:aws:iam::451934005581:role/GithubActions-Serverless-Lambda-Role",
        "arn:aws:iam::382373577178:role/GithubActions-Serverless-Lambda-Role"

      ]
    }
  }
}
