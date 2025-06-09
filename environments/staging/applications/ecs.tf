module "ecs" {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs?ref=v5.12.1"

  cluster_name = "trade-tariff-cluster-${var.environment}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/trade-tariff-ecs-${var.environment}"
      }
    }
  }

  default_capacity_provider_use_fargate = true

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
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
          AWS = "arn:aws:iam::${local.account_id}:root"
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
