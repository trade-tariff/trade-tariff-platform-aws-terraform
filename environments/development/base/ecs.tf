module "ecs" {
  source = "github.com/trade-tariff/terraform-aws-ecs?ref=57244e69abea685f7d45352abc994779b5f6d352"

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

  # TODO
  # add autoscaling_capacity_providers
}

resource "aws_kms_key" "log_key" {
  description             = "CloudWatch Log Key"
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/trade-tariff-ecs-${var.environment}"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.log_key.key_id
}
