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

run "creates_log_group_named_after_the_function" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/aws/lambda/test-function"
    error_message = "The log group name must be /aws/lambda/ followed by the function name."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.retention_in_days == 14
    error_message = "Log retention must default to 14 days."
  }
}

run "function_logs_to_the_module_log_group" {
  command = plan

  assert {
    condition     = aws_lambda_function.this.logging_config[0].log_group == "/aws/lambda/test-function"
    error_message = "The function must send its logs to the log group that the module creates."
  }

  assert {
    condition     = aws_lambda_function.this.logging_config[0].log_format == "Text"
    error_message = "The function log format must be Text."
  }
}

run "function_runs_as_the_module_role" {
  command = plan

  override_resource {
    target          = aws_iam_role.this
    override_during = plan
    values = {
      arn = "arn:aws:iam::123456789012:role/service-role/test-function-role"
    }
  }

  assert {
    condition     = aws_lambda_function.this.role == "arn:aws:iam::123456789012:role/service-role/test-function-role"
    error_message = "The function must run with the IAM role that the module creates."
  }

  assert {
    condition     = output.iam_role_arn == "arn:aws:iam::123456789012:role/service-role/test-function-role"
    error_message = "The iam_role_arn output must be the ARN of the module role."
  }
}
