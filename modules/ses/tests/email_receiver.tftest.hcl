mock_provider "random" {}

mock_provider "aws" {}

variables {
  domain_name        = "trade-tariff.example.gov.uk"
  route53_zone_id    = "Z0123456789ABCDEFGHIJ"
  receiving_endpoint = "inbound-smtp.eu-west-2.amazonaws.com"
  ses_inbound_bucket = "trade-tariff-ses-inbound"
  ses_iam_role       = "arn:aws:iam::123456789012:role/ses-inbound"
}

run "creates_no_receiving_resources_when_receiver_is_off" {
  command = plan

  variables {
    email_receiver = false
  }

  assert {
    condition     = length(aws_route53_record.mx) == 0
    error_message = "No MX record must be created when email_receiver is false."
  }

  assert {
    condition     = length(aws_ses_receipt_rule_set.this) == 0
    error_message = "No receipt rule set must be created when email_receiver is false."
  }

  assert {
    condition     = length(aws_ses_active_receipt_rule_set.this) == 0
    error_message = "No active receipt rule set must be created when email_receiver is false."
  }

  assert {
    condition     = length(aws_ses_receipt_rule.receive_all) == 0
    error_message = "No receipt rule must be created when email_receiver is false."
  }
}

run "creates_receiving_resources_when_receiver_is_on" {
  command = plan

  variables {
    email_receiver = true
  }

  assert {
    condition     = length(aws_route53_record.mx) == 1
    error_message = "One MX record must be created when email_receiver is true."
  }

  assert {
    condition     = length(aws_ses_receipt_rule_set.this) == 1
    error_message = "One receipt rule set must be created when email_receiver is true."
  }

  assert {
    condition     = length(aws_ses_active_receipt_rule_set.this) == 1
    error_message = "One active receipt rule set must be created when email_receiver is true."
  }

  assert {
    condition     = length(aws_ses_receipt_rule.receive_all) == 1
    error_message = "One receipt rule must be created when email_receiver is true."
  }
}

run "mx_record_points_to_receiving_endpoint" {
  command = plan

  variables {
    email_receiver = true
  }

  assert {
    condition     = aws_route53_record.mx[0].name == "trade-tariff.example.gov.uk"
    error_message = "The MX record must be on the domain itself."
  }

  assert {
    condition     = aws_route53_record.mx[0].records == toset(["10 inbound-smtp.eu-west-2.amazonaws.com"])
    error_message = "The MX record must point to the receiving endpoint with priority 10."
  }
}

run "receipt_rule_scans_mail_and_stores_it_in_s3" {
  command = plan

  variables {
    email_receiver = true
  }

  assert {
    condition     = aws_ses_active_receipt_rule_set.this[0].rule_set_name == aws_ses_receipt_rule_set.this[0].rule_set_name
    error_message = "The active rule set must be the rule set that the module creates."
  }

  assert {
    condition     = aws_ses_receipt_rule.receive_all[0].recipients == toset(["trade-tariff.example.gov.uk"])
    error_message = "The receipt rule must accept mail for the domain."
  }

  assert {
    condition     = aws_ses_receipt_rule.receive_all[0].scan_enabled == true
    error_message = "The receipt rule must scan incoming mail for spam and viruses."
  }

  assert {
    condition     = one(aws_ses_receipt_rule.receive_all[0].s3_action).bucket_name == "trade-tariff-ses-inbound"
    error_message = "The receipt rule must store mail in the inbound bucket."
  }

  assert {
    condition     = one(aws_ses_receipt_rule.receive_all[0].s3_action).object_key_prefix == "inbound/"
    error_message = "The receipt rule must store mail under the inbound/ prefix."
  }

  assert {
    condition     = one(aws_ses_receipt_rule.receive_all[0].s3_action).iam_role_arn == "arn:aws:iam::123456789012:role/ses-inbound"
    error_message = "The receipt rule must use the given IAM role to write to S3."
  }
}
