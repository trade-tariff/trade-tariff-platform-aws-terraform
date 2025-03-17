module "acm" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-acm?ref=v5.0.0"

  domain_name = "${var.cluster_name}.${data.aws_route53_zone.opensearch.name}"
  zone_id     = data.aws_route53_zone.opensearch.id

  validation_method   = "DNS"
  wait_for_validation = true

  tags = var.tags
}

resource "aws_iam_service_linked_role" "opensearch" {
  count            = var.create_service_role ? 1 : 0
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "opensearch" {
  domain_name     = var.cluster_name
  engine_version  = "OpenSearch_${var.cluster_version}"
  access_policies = data.aws_iam_policy_document.access_policy.json

  cluster_config {
    dedicated_master_enabled = var.master_instance_enabled
    dedicated_master_count   = var.master_instance_enabled ? var.master_instance_count : null
    dedicated_master_type    = var.master_instance_enabled ? var.master_instance_type : null

    instance_count = var.instance_count
    instance_type  = var.instance_type

    warm_enabled = var.warm_instance_enabled
    warm_count   = var.warm_instance_enabled ? var.warm_instance_count : null
    warm_type    = var.warm_instance_enabled ? var.warm_instance_type : null

    zone_awareness_enabled = (var.availability_zones > 1) ? true : false

    dynamic "zone_awareness_config" {
      for_each = (var.availability_zones > 1) ? [var.availability_zones] : []
      content {
        availability_zone_count = zone_awareness_config.value
      }
    }
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = local.master_user_username
      master_user_password = local.master_user_password
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"

    custom_endpoint_enabled         = true
    custom_endpoint                 = "${var.cluster_name}.${data.aws_route53_zone.opensearch.name}"
    custom_endpoint_certificate_arn = module.acm.acm_certificate_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.encrypt_kms_key_id
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
  }

  tags = var.tags

  depends_on = [aws_iam_service_linked_role.opensearch]
}


resource "aws_route53_record" "opensearch" {
  zone_id = data.aws_route53_zone.opensearch.id
  name    = var.cluster_name
  type    = "CNAME"
  ttl     = "60"

  records = [aws_opensearch_domain.opensearch.endpoint]
}


resource "aws_ssm_parameter" "opensearch_url" {
  name        = var.ssm_secret_name
  description = "OpenSearch access Credentials"
  type        = "SecureString"
  value       = "https://${local.master_user_username}:${local.master_user_password}@${aws_route53_record.opensearch.fqdn}"
}
