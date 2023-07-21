module "s3" {
  source  = "../../../modules/s3"
  s3_tags = var.s3_tags
}
