import {
  to = aws_securityhub_account.this
  id = "382373577178"
}

import {
  to = aws_securityhub_standards_subscription.aws_foundational_security_best_practices
  id = "arn:aws:securityhub:eu-west-2:382373577178:subscription/aws-foundational-security-best-practices/v/1.0.0"
}

import {
  to = aws_securityhub_standards_subscription.cis_aws_foundations_benchmark
  id = "arn:aws:securityhub:eu-west-2:382373577178:subscription/cis-aws-foundations-benchmark/v/5.0.0"
}

import {
  to = aws_guardduty_detector.this
  id = "0ecfedafb0e4905b12a029c86e54f5da"
}

import {
  for_each = local.guardduty_features

  to = aws_guardduty_detector_feature.this[each.key]
  id = "0ecfedafb0e4905b12a029c86e54f5da:${each.key}"
}

import {
  to = aws_inspector2_filter.suppress_no_fix_available
  id = "arn:aws:inspector2:eu-west-2:382373577178:owner/382373577178/filter/a266294e5f1baba7"
}

import {
  to = aws_config_configuration_recorder.default
  id = "default"
}

import {
  to = aws_config_delivery_channel.default
  id = "default"
}

import {
  to = aws_config_configuration_recorder_status.default
  id = "default"
}
