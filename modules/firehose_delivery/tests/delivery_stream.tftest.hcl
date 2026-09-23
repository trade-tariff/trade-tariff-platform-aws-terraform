mock_provider "aws" {}

variables {
  environment             = "staging"
  newrelic_license_key    = "test-licence-key"
  firehose_backups_bucket = "arn:aws:s3:::test-firehose-backups"
}

run "sends_to_eu_endpoint_by_default" {
  command = plan

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.nr_stream.http_endpoint_configuration[0].url == "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
    error_message = "The stream must send to the New Relic EU endpoint when newrelic_datacenter is EU."
  }
}

run "sends_to_us_endpoint_when_datacenter_is_us" {
  command = plan

  variables {
    newrelic_datacenter = "US"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.nr_stream.http_endpoint_configuration[0].url == "https://aws-api.newrelic.com/cloudwatch-metrics/v1"
    error_message = "The stream must send to the New Relic US endpoint when newrelic_datacenter is US."
  }
}

run "names_resources_by_environment" {
  command = plan

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.nr_stream.name == "cloudwatch-to-newrelic-staging"
    error_message = "The stream name must end with the environment."
  }

  assert {
    condition     = aws_iam_role.firehose_role.name == "newrelic-firehose-role-staging"
    error_message = "The IAM role name must end with the environment."
  }
}

run "backs_up_only_failed_data_to_the_bucket" {
  command = plan

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.nr_stream.http_endpoint_configuration[0].s3_backup_mode == "FailedDataOnly"
    error_message = "Only failed data must be backed up to S3."
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.nr_stream.http_endpoint_configuration[0].s3_configuration[0].bucket_arn == "arn:aws:s3:::test-firehose-backups"
    error_message = "Failed data must be backed up to the bucket that the caller gives."
  }
}
