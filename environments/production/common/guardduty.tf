locals {
  guardduty_features = {
    CLOUD_TRAIL            = { status = "ENABLED" }
    DNS_LOGS               = { status = "ENABLED" }
    FLOW_LOGS              = { status = "ENABLED" }
    S3_DATA_EVENTS         = { status = "ENABLED" }
    RDS_LOGIN_EVENTS       = { status = "ENABLED" }
    LAMBDA_NETWORK_LOGS    = { status = "ENABLED" }
    EBS_MALWARE_PROTECTION = { status = "ENABLED" }
    AI_PROTECTION          = { status = "ENABLED" }
    AI_ANALYST             = { status = "DISABLED" }
    EKS_AUDIT_LOGS         = { status = "DISABLED" }
    EKS_RUNTIME_MONITORING = {
      status = "DISABLED"
      additional_configuration = {
        EKS_ADDON_MANAGEMENT = "DISABLED"
      }
    }
    RUNTIME_MONITORING = {
      status = "ENABLED"
      additional_configuration = {
        ECS_FARGATE_AGENT_MANAGEMENT = "ENABLED"
        EC2_AGENT_MANAGEMENT         = "DISABLED"
        EKS_ADDON_MANAGEMENT         = "DISABLED"
      }
    }
  }
}

resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"
}

resource "aws_guardduty_detector_feature" "this" {
  for_each = local.guardduty_features

  detector_id = aws_guardduty_detector.this.id
  name        = each.key
  status      = each.value.status

  dynamic "additional_configuration" {
    for_each = lookup(each.value, "additional_configuration", {})

    content {
      name   = additional_configuration.key
      status = additional_configuration.value
    }
  }
}
