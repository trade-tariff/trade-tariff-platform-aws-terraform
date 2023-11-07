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
