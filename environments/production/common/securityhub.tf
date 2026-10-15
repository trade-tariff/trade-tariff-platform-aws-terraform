resource "aws_securityhub_account" "this" {
  auto_enable_controls      = true
  control_finding_generator = "SECURITY_CONTROL"
  enable_default_standards  = false

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_securityhub_standards_subscription" "aws_foundational_security_best_practices" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/cis-aws-foundations-benchmark/v/5.0.0"

  depends_on = [aws_securityhub_account.this]
}
