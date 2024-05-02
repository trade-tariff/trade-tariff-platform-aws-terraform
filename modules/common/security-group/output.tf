output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "ecs_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "be_to_rds_security_group_id" {
  value = aws_security_group.be_to_rds_ingress.id
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}
