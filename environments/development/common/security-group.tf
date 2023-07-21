resource "aws_security_group" "alb_security_group" {
  name        = "trade-tariff-alb-security-group-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  # tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "HTTPS Ingress from CDN"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "Allow All Egress From VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Trade Tariff ALB Security Group"
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "trade-tariff-ecs-security-group-${var.environment}"
  description = "Allow HTTP/S ingress, all egress"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  # ingress traffic from alb
  ingress {
    description = "HTTP Access from ALB"
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "HTTPS Access From ALB"
    from_port   = 443
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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

resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Security group for the database."
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description     = "Traffic from ECS"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  egress {
    description     = "Traffic to ECS"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs_security_group.id]
  }
}
