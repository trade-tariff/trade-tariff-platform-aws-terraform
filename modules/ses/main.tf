resource "aws_ses_domain_identity" "this" {
  domain = var.domain_name
}

resource "aws_route53_record" "this" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.this.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.this.verification_token]
}

resource "aws_ses_domain_identity_verification" "this" {
  domain     = aws_ses_domain_identity.this.id
  depends_on = [aws_route53_record.this]
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mx" {
  count   = var.email_receiver ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 600
  records = ["10 ${var.receiving_endpoint}"]
}

resource "aws_ses_receipt_rule_set" "this" {
  count         = var.email_receiver ? 1 : 0
  rule_set_name = "default-rule-set"
}

resource "aws_ses_active_receipt_rule_set" "this" {
  count         = var.email_receiver ? 1 : 0
  rule_set_name = aws_ses_receipt_rule_set.this[0].rule_set_name
}

resource "aws_ses_receipt_rule" "receive_all" {
  count         = var.email_receiver ? 1 : 0
  name          = "receive-all"
  rule_set_name = aws_ses_receipt_rule_set.this[0].rule_set_name
  recipients    = [var.domain_name]
  enabled       = true
  scan_enabled  = true
  tls_policy    = "Optional"

  s3_action {
    position          = 1
    bucket_name       = var.ses_inbound_bucket
    object_key_prefix = "inbound/"
  }
}
