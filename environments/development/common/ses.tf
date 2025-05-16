module "ses" {
  source          = "../../../modules/ses"
  domain_name     = var.domain_name
  route53_zone_id = data.aws_route53_zone.this.zone_id

  email_receiver     = true
  receiving_endpoint = "inbound-smtp.${var.region}.amazonaws.com"
  ses_inbound_bucket = aws_s3_bucket.this["ses-inbound"].bucket
  ses_iam_role       = aws_iam_role.ses_s3.arn
}
