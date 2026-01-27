data "aws_iam_policy_document" "nr_linked_account_trust" {
  statement {
    sid     = "AllowNewRelicToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.newrelic_aws_trusted_account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [tostring(local.newrelic_account_id)]
    }
  }
}

resource "aws_iam_role" "nr_linked_account" {
  name               = "newrelic-infrastructure-integrations"
  assume_role_policy = data.aws_iam_policy_document.nr_linked_account_trust.json
  description        = "New Relic Linked Account role (External ID = NR account ID)."
}

resource "aws_iam_role_policy_attachment" "nr_linked_account_readonly" {
  role       = aws_iam_role.nr_linked_account.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


resource "newrelic_cloud_aws_link_account" "production" {
  arn                    = aws_iam_role.nr_linked_account.arn
  metric_collection_mode = "PUSH"
  name                   = "production"
}
