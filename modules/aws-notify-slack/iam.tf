locals {
  create_sns_feedback_role = local.create && var.create_sns_topic && var.enable_sns_topic_delivery_status_logs && var.sns_topic_lambda_feedback_role_arn == ""
}

resource "aws_iam_role" "sns_feedback_role" {
  count = local.create_sns_feedback_role ? 1 : 0

  name                  = var.sns_topic_feedback_role_name
  description           = var.sns_topic_feedback_role_description
  path                  = var.sns_topic_feedback_role_path
  force_detach_policies = var.sns_topic_feedback_role_force_detach_policies
  permissions_boundary  = var.sns_topic_feedback_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "sns.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, var.sns_topic_feedback_role_tags)
}
