moved {
  from = module.cdn.aws_route53_record.alias_record[0]
  to   = module.cdn.aws_route53_record.alias_record["trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[1]
  to   = module.cdn.aws_route53_record.alias_record["admin.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[2]
  to   = module.cdn.aws_route53_record.alias_record["hub.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[3]
  to   = module.cdn.aws_route53_record.alias_record["new-hub.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[4]
  to   = module.cdn.aws_route53_record.alias_record["tea.trade-tariff.service.gov.uk"]
}

moved {
  from = module.cdn.aws_route53_record.alias_record[5]
  to   = module.cdn.aws_route53_record.alias_record["www.trade-tariff.service.gov.uk"]
}

moved {
  from = module.api_cdn.aws_route53_record.alias_record[0]
  to   = module.api_cdn.aws_route53_record.alias_record["api.trade-tariff.service.gov.uk"]
}

moved {
  from = module.backups_cdn.aws_route53_record.alias_record[0]
  to   = module.backups_cdn.aws_route53_record.alias_record["dumps.trade-tariff.service.gov.uk"]
}

moved {
  from = module.reporting_cdn.aws_route53_record.alias_record[0]
  to   = module.reporting_cdn.aws_route53_record.alias_record["reporting.trade-tariff.service.gov.uk"]
}

moved {
  from = module.status_checks_cdn.aws_route53_record.alias_record[0]
  to   = module.status_checks_cdn.aws_route53_record.alias_record["status.trade-tariff.service.gov.uk"]
}

moved {
  from = module.tech_docs_cdn.aws_route53_record.alias_record[0]
  to   = module.tech_docs_cdn.aws_route53_record.alias_record["docs.trade-tariff.service.gov.uk"]
}
