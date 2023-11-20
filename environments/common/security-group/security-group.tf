data "aws_region" "current" {}

data "aws_ec2_managed_prefix_list" "this" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_security_group" "alb_security_group" {
  name        = "trade-tariff-alb-security-group-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP Ingress from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Ingress from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
  vpc_id      = var.vpc_id

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

resource "aws_security_group" "be_to_rds_ingress" {
  name        = "trade-tariff-be-rd-${var.environment}"
  description = "Allow Ingress from Backend to RDS Instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress from private subnets to Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    description = "Egress back out from Postgres to private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  ingress {
    description = "Ingress from private subnets to MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    description = "Egress back out from MySQL to private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    description     = "Egress to S3 via VPC endpoint for database backups."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.this.id]
  }

  tags = {
    Name = "Backend to RDS Ingress Security Group"
  }
}

resource "aws_security_group" "redis" {
  name        = "trade-tariff-redis-security-group-${var.environment}"
  description = "Traffic flow between Elasticache and ECS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress from private subnets"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    description = "Egress back out to private subnets"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  tags = {
    Name = "Redis Security Group"
  }
}
