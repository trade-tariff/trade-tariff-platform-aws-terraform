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
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/opensearch?ref=474bad3"

  cluster_name    = "tariff-search-${var.environment}"
  cluster_domain  = var.domain_name
  cluster_version = "2.3"

  master_instance_enabled = false
  warm_instance_enabled   = false
  instance_count          = 3
  instance_type           = "m5.xlarge.search"
  ebs_volume_size         = 80

  create_master_user = true
  encrypt_kms_key_id = aws_kms_key.opensearch_kms_key.key_id
  ssm_secret_name    = "/${var.environment}/ELASTICSEARCH_URL"
}

resource "aws_iam_user" "opensearch" {
  name = "tariff-opensearch-user"
}

data "aws_iam_policy_document" "opensearch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["es:*"]
    resources = [module.opensearch.domain_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:AbortUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:ListObjectsV2",
      "s3:ListUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject"
    ]
    resources = [
      module.opensearch_packages_bucket.s3_bucket_arn,
      "${module.opensearch_packages_bucket.s3_bucket_arn}/*",
      module.search_configuration_bucket.s3_bucket_arn,
      "${module.search_configuration_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "opensearch" {
  name   = "opensearch-policy"
  policy = data.aws_iam_policy_document.opensearch_policy.json
}

resource "aws_iam_user_policy_attachment" "opensearch" {
  user       = aws_iam_user.opensearch.name
  policy_arn = aws_iam_policy.opensearch.arn
}
