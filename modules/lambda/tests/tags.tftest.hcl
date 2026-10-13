mock_provider "aws" {
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

run "has_no_tags_by_default" {
  command = plan

  assert {
    condition     = length(aws_lambda_function.this.tags) == 0 && length(aws_cloudwatch_log_group.this.tags) == 0
    error_message = "The function and the log group must have no module tags when the caller gives none."
  }
}

run "tags_the_function_and_the_log_group" {
  command = plan

  variables {
    tags = { Component = "identity" }
  }

  assert {
    condition     = aws_lambda_function.this.tags == tomap({ Component = "identity" })
    error_message = "The function must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.tags == tomap({ Component = "identity" })
    error_message = "The log group must carry the tags that the caller gives."
  }
}
