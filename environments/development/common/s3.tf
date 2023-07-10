module "s3" {
  source  = "../../common/s3"
  s3_tags = var.s3_tags
}
