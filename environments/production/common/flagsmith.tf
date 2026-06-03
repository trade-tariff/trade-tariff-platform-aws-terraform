# Supporting infrastructure for self-hosted Flagsmith.
#
# Flagsmith itself (the API + edge-proxy ECS services) is deployed from the
# trade-tariff-flagsmith app repo via the shared ecs-service module, exactly
# like devhub/frontend/backend. This file only declares the shared resources
# that app reads via data sources: a dedicated database, security groups,
# configuration secrets, and the public-facing CloudFront distributions.

# ── Database ──────────────────────────────────────────────────────────────────
# Dedicated Postgres instance, isolated from the shared tariff cluster so
# Flagsmith's schema and load can't affect tariff data. The rds module also
# creates a "flagsmith-connection-string" secret the app reads as DATABASE_URL.
module "postgres_flagsmith" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "Flagsmith"
  engine         = "postgres"
  engine_version = "18.3"

  multi_az = true

  instance_type           = "db.t3.small"
  backup_window           = "22:00-23:00"
  maintenance_window      = "Fri:23:00-Sat:01:00"
  backup_retention_period = 7
  private_subnet_ids      = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage  = 20
  security_group_ids = [aws_security_group.flagsmith_rds.id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  depends_on = [
    aws_security_group.flagsmith_rds
  ]

  tags = {
    Name       = "FlagsmithPostgres${title(var.environment)}"
    "RDS_Type" = "Instance"
  }
}

# ── Security groups ───────────────────────────────────────────────────────────
# Flagsmith's upstream image serves plain HTTP on 8000 (no in-container TLS),
# so it gets a dedicated ECS security group rather than the shared 8443 one.
resource "aws_security_group" "flagsmith_ecs" {
  name        = "flagsmith-ecs-${var.environment}"
  description = "Flagsmith ECS tasks: HTTP 8000 from the ALB, all egress."
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description     = "HTTP 8000 from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.alb-security-group.alb_security_group_id]
  }

  egress {
    description = "Allow all egress (Docker Hub pulls, RDS, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flagsmith-ecs-${var.environment}"
  }
}

resource "aws_security_group" "flagsmith_rds" {
  name        = "flagsmith-rds-${var.environment}"
  description = "Flagsmith database: PostgreSQL from Flagsmith ECS tasks only."
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description     = "PostgreSQL from Flagsmith ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.flagsmith_ecs.id]
  }

  tags = {
    Name = "flagsmith-rds-${var.environment}"
  }
}

# ── Configuration secrets ─────────────────────────────────────────────────────
# Populated by operators after the first deploy (SECRET_KEY etc. for the API,
# the server-side environment key for the edge proxy).
module "flagsmith_configuration" {
  source          = "../../../modules/secret/"
  name            = "flagsmith-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "flagsmith_edge_configuration" {
  source          = "../../../modules/secret/"
  name            = "flagsmith-edge-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

# ── CloudFront ────────────────────────────────────────────────────────────────
# Flagsmith gets its own distributions rather than sharing the main CDN: its
# /api/v1/* paths would otherwise collide with the tariff API cache behaviours
# (long cache + auth lambda). Each distribution forwards the viewer Host header
# (via forward_all_qsa/allViewer) to the ALB origin, which routes flags.* and
# flags-edge.* to the Flagsmith HTTP target groups by host.
module "flags_cdn" {
  source = "../../../modules/cloudfront"

  aliases         = ["flags.${var.domain_name}"]
  create_alias    = true
  route53_zone_id = data.aws_route53_zone.this.id
  comment         = "Flagsmith ${title(var.environment)} CDN"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = module.waf.web_acl_id

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    alb = {
      domain_name = local.origin_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_read_timeout    = 60
      }

      custom_header = [{
        name  = random_password.origin_header[0].result
        value = random_password.origin_header[1].result
      }]
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "alb"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}

module "flags_edge_cdn" {
  source = "../../../modules/cloudfront"

  aliases         = ["flags-edge.${var.domain_name}"]
  create_alias    = true
  route53_zone_id = data.aws_route53_zone.this.id
  comment         = "Flagsmith Edge Proxy ${title(var.environment)} CDN"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = module.waf.web_acl_id

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    alb = {
      domain_name = local.origin_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_read_timeout    = 60
      }

      custom_header = [{
        name  = random_password.origin_header[0].result
        value = random_password.origin_header[1].result
      }]
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "alb"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}
