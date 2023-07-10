#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "application_load_balancer" {
  name               = "${var.alb_name}-${var.environment}"
  load_balancer_type = "application"
  internal           = false

  subnets                          = var.public_subnet_id
  security_groups                  = [var.alb_security_group_id]
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  drop_invalid_header_fields       = true
}

/* target group name cannot be longer than 30 char */
resource "aws_lb_target_group" "trade_tariff_target_groups" {
  for_each = toset([
    "trade-tariff-fe-tg-${var.environment}",
    "trade-tariff-be-tg-${var.environment}",
    "trade-tariff-dc-tg-${var.environment}",
  ])

  name        = each.value
  port        = var.application_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = "10"
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    protocol            = "HTTP"
    matcher             = "200"
  }
}

/* target group name cannot be longer than 30 char */
resource "aws_lb_listener" "trade_tariff_listeners" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.listening_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trade_tariff_target_groups["trade-tariff-fe-tg-${var.environment}"].arn
  }
}

resource "aws_lb_listener_rule" "trade_tariff_backend_listeners_rules" {
  listener_arn = aws_lb_listener.trade_tariff_listeners.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trade_tariff_target_groups["trade-tariff-be-tg-${var.environment}"].arn
  }

  ## have to ideal for now
  condition {
    path_pattern {
      values = ["/backend/*"]
    }
  }
}

resource "aws_lb_listener_rule" "trade_tariff_duty_cal_listeners_rules" {
  listener_arn = aws_lb_listener.trade_tariff_listeners.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trade_tariff_target_groups["trade-tariff-dc-tg-${var.environment}"].arn
  }

  ## have to ideal for now
  condition {
    path_pattern {
      values = ["/duty-calulator/*"]
    }
  }
}
