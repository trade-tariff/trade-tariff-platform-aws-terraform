resource "aws_kms_key" "opensearch_kms_key" {
  description             = "KMS key for encrypting OpenSearch cluster and buckets."
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "opensearch_kms_alias" {
  name          = "alias/opensearch-key"
  target_key_id = aws_kms_key.opensearch_kms_key.key_id
}

module "opensearch_packages_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v5.1.0"

  bucket = "trade-tariff-opensearch-packages-${local.account_id}"
  acl    = "private"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.opensearch_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  logging = {
    target_bucket = module.logs.s3_bucket_id
    target_prefix = "log/"
  }
}

module "search_configuration_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v5.1.0"

  bucket = "trade-tariff-search-configuration-${local.account_id}"
  acl    = "private"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.opensearch_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  logging = {
    target_bucket = module.logs.s3_bucket_id
    target_prefix = "log/"
  }
}

module "opensearch" {
  source = "../../../modules/opensearch"

  cluster_name    = "tariff-search-${var.environment}"
  cluster_domain  = var.domain_name
  cluster_version = "3.5"

  master_instance_enabled = false
  warm_instance_enabled   = false
  instance_count          = 3
  instance_type           = "m6g.xlarge.search"
  ebs_volume_size         = 80

  create_master_user = true
  encrypt_kms_key_id = aws_kms_key.opensearch_kms_key.key_id
  ssm_secret_name    = "/${var.environment}/ELASTICSEARCH_URL"
}

#----------------------------------------------------------#
# CloudWatch alarms for OpenSearch cluster health
#----------------------------------------------------------#

resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_red" {
  alarm_name          = "opensearch-cluster-red-${var.environment}"
  alarm_description   = "OpenSearch cluster status is RED — at least one primary shard is unassigned"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = "tariff-search-${var.environment}"
    ClientId   = local.account_id
  }

  alarm_actions = local.alert_actions
}

resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_yellow" {
  alarm_name          = "opensearch-cluster-yellow-${var.environment}"
  alarm_description   = "OpenSearch cluster status is YELLOW — replica shards unassigned"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = 120
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = "tariff-search-${var.environment}"
    ClientId   = local.account_id
  }

  alarm_actions = local.observability_alert_actions
}

resource "aws_cloudwatch_metric_alarm" "opensearch_free_storage" {
  alarm_name          = "opensearch-low-storage-${var.environment}"
  alarm_description   = "OpenSearch free storage is below 10GB"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = 300
  statistic           = "Minimum"
  threshold           = 10000
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = "tariff-search-${var.environment}"
    ClientId   = local.account_id
  }

  alarm_actions = local.alert_actions
}

resource "aws_cloudwatch_metric_alarm" "opensearch_jvm_pressure" {
  alarm_name          = "opensearch-jvm-pressure-${var.environment}"
  alarm_description   = "OpenSearch JVM memory pressure above 85%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = 300
  statistic           = "Maximum"
  threshold           = 85
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = "tariff-search-${var.environment}"
    ClientId   = local.account_id
  }

  alarm_actions = local.observability_alert_actions
}
