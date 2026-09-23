mock_provider "aws" {}

variables {
  environment  = "staging"
  firehose_arn = "arn:aws:firehose:eu-west-2:123456789012:deliverystream/new-relic-metrics"
}

run "names_stream_and_role_after_environment" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_stream.nr_metric_stream.name == "cw-metric-stream-nr-staging"
    error_message = "The metric stream must be named cw-metric-stream-nr-<environment>."
  }

  assert {
    condition     = aws_iam_role.metric_stream_role.name == "metric-stream-role-staging"
    error_message = "The IAM role must be named metric-stream-role-<environment>."
  }

  assert {
    condition     = output.metric_stream_name == "cw-metric-stream-nr-staging"
    error_message = "The metric_stream_name output must be the name of the metric stream."
  }
}

run "streams_all_metrics_when_no_filters_are_given" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_metric_stream.nr_metric_stream.include_filter) == 0
    error_message = "The metric stream must have no include filters when include_metric_filters is empty."
  }
}

run "creates_one_include_filter_per_namespace" {
  command = plan

  variables {
    include_metric_filters = {
      "AWS/ECS" = ["CPUUtilization", "MemoryUtilization"]
      "AWS/RDS" = []
    }
  }

  assert {
    condition     = length(aws_cloudwatch_metric_stream.nr_metric_stream.include_filter) == 2
    error_message = "The metric stream must have one include filter for each namespace."
  }

  assert {
    condition     = toset([for filter in aws_cloudwatch_metric_stream.nr_metric_stream.include_filter : filter.namespace]) == toset(["AWS/ECS", "AWS/RDS"])
    error_message = "The include filter namespaces must be the keys of include_metric_filters."
  }

  assert {
    condition     = one([for filter in aws_cloudwatch_metric_stream.nr_metric_stream.include_filter : filter.metric_names if filter.namespace == "AWS/ECS"]) == toset(["CPUUtilization", "MemoryUtilization"])
    error_message = "The include filter metric names must be the values of include_metric_filters."
  }
}

run "role_can_only_be_assumed_by_cloudwatch_metric_streams" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.metric_stream_role.assume_role_policy).Statement[0].Principal.Service == "streams.metrics.cloudwatch.amazonaws.com"
    error_message = "Only the CloudWatch metric streams service must be able to assume the role."
  }
}

run "role_can_only_write_to_the_given_firehose" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role_policy.metric_stream_policy.policy).Statement[1].Resource == "arn:aws:firehose:eu-west-2:123456789012:deliverystream/new-relic-metrics"
    error_message = "The Firehose statement must be limited to the given firehose_arn."
  }

  assert {
    condition     = toset(jsondecode(aws_iam_role_policy.metric_stream_policy.policy).Statement[1].Action) == toset(["firehose:PutRecord", "firehose:PutRecordBatch"])
    error_message = "The Firehose statement must only allow PutRecord and PutRecordBatch."
  }
}
