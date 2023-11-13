data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:AddPermission",
      "sns:DeleteTopic",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:Subscribe",
    ]
    resources = [aws_sns_topic.rds.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = local.account_id
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.rds.arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "rds.amazonaws.com",
      ]
    }
  }
}

resource "aws_sns_topic" "rds" {
  name = "rds-events"
}

resource "aws_sns_topic_policy" "db_event_policy" {
  arn    = aws_sns_topic.rds.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_db_event_subscription" "this" {
  name      = "rds-event-subscription"
  sns_topic = aws_sns_topic.rds.arn

  source_type = "db-snapshot"
  source_ids  = [module.postgres.db_id]

  event_categories = [
    "creation",
    "notification"
  ]

  depends_on = [aws_sns_topic_policy.db_event_policy]
}
