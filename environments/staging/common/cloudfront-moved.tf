moved {
  from = module.cdn.aws_route53_record.alias_record[0]
  to   = module.cdn.aws_route53_record.alias_record["staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[1]
  to   = module.cdn.aws_route53_record.alias_record["admin.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[2]
  to   = module.cdn.aws_route53_record.alias_record["hub.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[3]
  to   = module.cdn.aws_route53_record.alias_record["new-hub.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[4]
  to   = module.cdn.aws_route53_record.alias_record["tea.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.api_cdn.aws_route53_record.alias_record[0]
  to   = module.api_cdn.aws_route53_record.alias_record["api.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.backups_cdn.aws_route53_record.alias_record[0]
  to   = module.backups_cdn.aws_route53_record.alias_record["dumps.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.reporting_cdn.aws_route53_record.alias_record[0]
  to   = module.reporting_cdn.aws_route53_record.alias_record["reporting.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.status_checks_cdn.aws_route53_record.alias_record[0]
  to   = module.status_checks_cdn.aws_route53_record.alias_record["status.staging.trade-tariff.service.gov.uk"]
}

moved {
  from = module.tech_docs_cdn.aws_route53_record.alias_record[0]
  to   = module.tech_docs_cdn.aws_route53_record.alias_record["docs.staging.trade-tariff.service.gov.uk"]
}
