mock_provider "aws" {
  override_data {
    target = data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }
}

variables {
  environment     = "development"
  vpc_id          = "vpc-00000000000000000"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}

run "names_every_security_group_after_the_environment" {
  command = plan

  assert {
    condition     = aws_security_group.alb_security_group.name == "trade-tariff-alb-security-group-development"
    error_message = "The ALB security group name must end with the environment."
  }

  assert {
    condition     = aws_security_group.ecs_security_group.name == "trade-tariff-ecs-security-group-development"
    error_message = "The ECS security group name must end with the environment."
  }

  assert {
    condition     = aws_security_group.be_to_rds_ingress.name == "trade-tariff-be-rd-development"
    error_message = "The backend to RDS security group name must end with the environment."
  }

  assert {
    condition     = aws_security_group.redis.name == "trade-tariff-redis-security-group-development"
    error_message = "The Redis security group name must end with the environment."
  }
}

run "opens_only_http_and_https_to_the_internet_on_the_alb" {
  command = plan

  assert {
    condition     = toset([for rule in aws_security_group.alb_security_group.ingress : rule.from_port]) == toset([80, 443])
    error_message = "The ALB security group must only allow ingress on ports 80 and 443."
  }

  assert {
    condition     = alltrue([for rule in aws_security_group.alb_security_group.ingress : rule.from_port == rule.to_port])
    error_message = "Each ALB ingress rule must open a single port."
  }
}

run "limits_database_traffic_to_the_private_subnets" {
  command = plan

  assert {
    condition     = toset([for rule in aws_security_group.be_to_rds_ingress.ingress : rule.from_port]) == toset([5432, 3306])
    error_message = "The backend to RDS security group must only allow Postgres and MySQL ingress."
  }

  assert {
    condition     = alltrue([for rule in aws_security_group.be_to_rds_ingress.ingress : rule.cidr_blocks == tolist(["10.0.1.0/24", "10.0.2.0/24"])])
    error_message = "Database ingress must only come from the private subnets."
  }

  assert {
    condition = alltrue([
      for rule in aws_security_group.be_to_rds_ingress.egress :
      rule.cidr_blocks == tolist(["10.0.1.0/24", "10.0.2.0/24"])
      if rule.from_port != 443
    ])
    error_message = "Database egress on the database ports must only go to the private subnets."
  }
}

run "limits_redis_traffic_to_the_private_subnets" {
  command = plan

  assert {
    condition     = alltrue([for rule in aws_security_group.redis.ingress : rule.from_port == 6379 && rule.cidr_blocks == tolist(["10.0.1.0/24", "10.0.2.0/24"])])
    error_message = "Redis ingress must only allow port 6379 from the private subnets."
  }

  assert {
    condition     = alltrue([for rule in aws_security_group.redis.egress : rule.from_port == 6379 && rule.cidr_blocks == tolist(["10.0.1.0/24", "10.0.2.0/24"])])
    error_message = "Redis egress must only allow port 6379 to the private subnets."
  }
}

run "looks_up_the_s3_prefix_list_for_the_current_region" {
  command = plan

  assert {
    condition     = data.aws_ec2_managed_prefix_list.this.name == "com.amazonaws.eu-west-2.s3"
    error_message = "The S3 prefix list lookup must use the current region."
  }
}
