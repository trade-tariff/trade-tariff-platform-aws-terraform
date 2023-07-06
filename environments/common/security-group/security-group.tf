# application load balancer Security Group
# This is to supress tfsec erroring allow all ingress traffic to the load balancer

# tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group" "alb_security_group" {
  name        = "trade-tariff-alb-security-group-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_traffic]
  }

  egress {
    description = "Allow All Egress From VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

  tags = {
    Name = "Trade Tariff ALB Security Group"
  }
}

/* Security group for the ecs application */
resource "aws_security_group" "ecs_security_group" {
  name        = "trade-tariff-ecs-security-group-${var.environment}"
  description = "Allow TLS ingress, all egress"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  # ingress traffic from alb
  ingress {
    description     = "HTTPS Access From ALB"
    from_port       = 443
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  # We want egress out to the public internet here
  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "Allow All Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS Security Group"
  }
}
