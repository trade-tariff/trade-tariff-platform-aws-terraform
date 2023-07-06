# tfsec ignores are in place as:
# - we do not need versioning on these buckets
# - it is not correctly identifying the encryption

resource "aws_kms_key" "opensearch_kms_key" {
  description             = "KMS key for encrypting OpenSearch cluster and buckets."
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "opensearch_kms_alias" {
  name          = "alias/opensearch-key"
  target_key_id = aws_kms_key.opensearch_kms_key.key_id
}

#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
module "opensearch_packages_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.14.0"

  bucket = "trade-tariff-opensearch-packages-${local.account_id}"
  acl    = "private"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.opensearch_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  logging = {
    target_bucket = module.logs.s3_bucket_id
    target_prefix = "log/"
  }
}

#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
module "search_configuration_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.14.0"

  bucket = "trade-tariff-search-configuration-${local.account_id}"
  acl    = "private"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.opensearch_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  logging = {
    target_bucket = module.logs.s3_bucket_id
    target_prefix = "log/"
  }
}

module "opensearch" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/opensearch?ref=aws/opensearch-v1.0.0"

  cluster_name    = "tariff-search-${var.environment}"
  cluster_domain  = var.domain_name
  cluster_version = "2.3"

  master_instance_enabled = false
  warm_instance_enabled   = false
  instance_count          = 3
  instance_type           = "t3.small.search" # small one for dev :)
  ebs_volume_size         = 80

  create_service_role = true
  create_master_user  = true
  encrypt_kms_key_id  = aws_kms_key.opensearch_kms_key.key_id
  ssm_secret_name     = "/${var.environment}/ELASTICSEARCH_URL"
}
