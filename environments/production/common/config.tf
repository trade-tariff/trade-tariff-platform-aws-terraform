locals {
  config_daily_resource_types = [
    "AWS::EC2::VPC",
    "AWS::ECS::TaskDefinition",
    "AWS::ECS::Service",
    "AWS::ElasticLoadBalancingV2::LoadBalancer",
    "AWS::WAFv2::WebACL",
  ]

  config_continuous_resource_types = [
    "AWS::EC2::Instance",
    "AWS::EC2::SecurityGroup",
    "AWS::EC2::Volume",
    "AWS::S3::Bucket",
    "AWS::RDS::DBInstance",
    "AWS::RDS::DBSnapshot",
    "AWS::IAM::Role",
    "AWS::IAM::Policy",
    "AWS::IAM::User",
    "AWS::RDS::DBCluster",
    "AWS::RDS::DBClusterSnapshot",
    "AWS::CloudTrail::Trail",
    "AWS::KMS::Key",
    "AWS::EC2::NetworkInterface",
    "AWS::Lambda::Function",
  ]
}

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = "arn:aws:iam::${local.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = concat(local.config_daily_resource_types, local.config_continuous_resource_types)

    recording_strategy {
      use_only = "INCLUSION_BY_RESOURCE_TYPES"
    }
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"

    recording_mode_override {
      description         = "Record high-churn resource types daily"
      recording_frequency = "DAILY"
      resource_types      = local.config_daily_resource_types
    }
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = "config-bucket-${local.account_id}"

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.default]
}
