module "ecs" {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs?ref=v6.7.0"

  cluster_name = "trade-tariff-cluster-${var.environment}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloudwatch_log_group_retention_in_days = 7
      }
    }
  }

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }
}

resource "aws_kms_key" "log_key" {
  description             = "CloudWatch Log Key"
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "kms:*",
        Effect   = "Allow"
        Resource = "*"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
      {
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "tariff.internal"
  description = "Private DNS namespace."
  vpc         = data.terraform_remote_state.base.outputs.vpc_id
}

resource "aws_cloudwatch_log_group" "container_insights_performance" {
  name              = "/aws/ecs/containerinsights/trade-tariff-cluster-${var.environment}/performance"
  retention_in_days = 1
}

import {
  to = aws_cloudwatch_log_group.container_insights_performance
  id = "/aws/ecs/containerinsights/trade-tariff-cluster-${var.environment}/performance"
}
