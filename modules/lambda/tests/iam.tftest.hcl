mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.current
    values = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }

  # Mock data sources return a random string for json. The IAM resources
  # reject that at plan, so give them a valid (empty) policy document.
  override_data {
    target = data.aws_iam_policy_document.logs
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.assume_role_policy
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  function_name    = "test-function"
  filename         = "test-function.zip"
  handler          = "handler.lambda_handler"
  source_code_hash = "dGVzdC1oYXNo"
  runtime          = "python3.12"
}

run "role_and_logs_policy_are_named_after_the_function" {
  command = plan

  assert {
    condition     = aws_iam_role.this.name == "test-function-role"
    error_message = "The IAM role name must be the function name with a -role suffix."
  }

  assert {
    condition     = aws_iam_role.this.path == "/service-role/"
    error_message = "The IAM role must be in the /service-role/ path."
  }

  assert {
    condition     = aws_iam_policy.this.name == "test-function-logs-policy"
    error_message = "The logs policy name must be the function name with a -logs-policy suffix."
  }
}

run "only_lambda_can_assume_the_role" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.assume_role_policy.statement) == 1
    error_message = "The assume role policy must have exactly one statement."
  }

  assert {
    condition     = data.aws_iam_policy_document.assume_role_policy.statement[0].actions == toset(["sts:AssumeRole"])
    error_message = "The assume role policy must allow only sts:AssumeRole."
  }

  assert {
    condition = [
      for principal in data.aws_iam_policy_document.assume_role_policy.statement[0].principals :
      { type = principal.type, identifiers = principal.identifiers }
      ] == [
      { type = "Service", identifiers = toset(["lambda.amazonaws.com"]) }
    ]
    error_message = "Only the lambda.amazonaws.com service principal must be able to assume the role."
  }
}

run "logs_policy_is_scoped_to_account_and_region" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.logs.statement) == 1
    error_message = "The logs policy must have exactly one statement."
  }

  assert {
    condition = data.aws_iam_policy_document.logs.statement[0].actions == toset([
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ])
    error_message = "The logs policy must allow only the three CloudWatch Logs write actions."
  }

  assert {
    condition     = data.aws_iam_policy_document.logs.statement[0].resources == toset(["arn:aws:logs:eu-west-2:123456789012:*"])
    error_message = "The logs policy must be scoped to CloudWatch Logs in the current account and region."
  }
}

run "attaches_no_additional_policies_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role_policy_attachment.additional_policies) == 0
    error_message = "No additional policy attachments must be created when additional_policy_arns is empty."
  }
}

run "attaches_each_additional_policy_to_the_role" {
  command = plan

  variables {
    additional_policy_arns = [
      "arn:aws:iam::123456789012:policy/first-policy",
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    ]
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.additional_policies) == 2
    error_message = "One policy attachment must be created for each additional policy ARN."
  }

  assert {
    condition = [for attachment in aws_iam_role_policy_attachment.additional_policies : attachment.policy_arn] == [
      "arn:aws:iam::123456789012:policy/first-policy",
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    ]
    error_message = "The additional policy attachments must use the given ARNs in order."
  }

  assert {
    condition     = alltrue([for attachment in aws_iam_role_policy_attachment.additional_policies : attachment.role == "test-function-role"])
    error_message = "Every additional policy must be attached to the function role."
  }
}
