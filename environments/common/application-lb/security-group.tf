module "web_server_sg" {
  source = "github.com/trade-tariff/terraform-aws-security-group"

  name        = "trade-tariff-cluster-${var.environment}"
  description = "Security group for web-server to allow all ingresss"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [" 0.0.0.0 "]
}