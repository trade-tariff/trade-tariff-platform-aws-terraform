data "terraform_remote_state" "development" {
  backend = "s3"

  config = {
    bucket = "terraform-state-development-844815912454"
    key    = "common/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "staging" {
  backend = "s3"

  config = {
    bucket = "terraform-state-staging-451934005581"
    key    = "common/terraform.tfstate"
    region = var.region
  }
}

resource "aws_route53_zone" "lower_env" {
  for_each = to_set(["dev", "staging", "sandbox"])
  name     = "${each.key}.${local.tariff_domain}"
}

resource "aws_route53_record" "dev_name_servers" {
  zone_id = aws_route53_zone.lower_env["dev"].zone_id
  name    = "dev.${local.tariff_domain}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.development.outputs.hosted_zone_name_servers
}

resource "aws_route53_record" "staging_name_servers" {
  zone_id = aws_route53_zone.lower_env["staging"].zone_id
  name    = "staging.${local.tariff_domain}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.staging.outputs.hosted_zone_name_servers
}

resource "aws_route53_record" "sandbox_name_servers" {
  zone_id = aws_route53_zone.lower_env["sandbox"].zone_id
  name    = "sandbox.${local.tariff_domain}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.staging.outputs.sandbox_hosted_zone_name_servers
}
