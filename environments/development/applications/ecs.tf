module "ecs" {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs?ref=f3c9f66"

  cluster_name = "trade-tariff-cluster-${var.environment}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/trade-tariff-ecs-${var.environment}"
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
