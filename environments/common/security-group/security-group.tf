/* application load balancer Security Group */
/* This is to supress tfsec erroring allow all ingress traffic to the load balancer */
#  tfsec:ignore:aws-ec2-no-public-ingress-sgr
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
  name        = "trade-tariff-allipcation-security-group-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  # ingres traffic from alb
  ingress {
    description     = "Https Access From Alb"
    from_port       = 443
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    description = "Allow All Egress From VPC"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.cidr_block]
  }

  tags = {
    Name = "ECS Security Group"
  }
}
