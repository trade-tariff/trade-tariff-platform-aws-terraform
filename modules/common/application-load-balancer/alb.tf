resource "aws_lb" "application_load_balancer" {
  name               = var.alb_name
  load_balancer_type = "application"
  internal           = false

  subnets                          = var.public_subnet_ids
  security_groups                  = [var.alb_security_group_id]
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  drop_invalid_header_fields       = true
}

/* target group name cannot be longer than 32 chars */
resource "aws_lb_target_group" "trade_tariff_target_groups" {
  for_each             = var.services
  name                 = replace(each.key, "_", "-")
  port                 = var.application_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 20

  health_check {
    enabled             = true
    interval            = 60
    path                = each.value.healthcheck_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "redirect_http" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "trade_tariff_listeners" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.listening_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each     = var.services
  listener_arn = aws_lb_listener.trade_tariff_listeners.arn

  priority = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trade_tariff_target_groups[each.key].arn
  }

  dynamic "condition" {
    for_each = lookup(var.services[each.key], "hosts", null) != null ? [true] : []
    content {
      host_header {
        values = each.value.hosts
      }
    }
  }

  dynamic "condition" {
    for_each = lookup(var.services[each.key], "paths", null) != null ? [true] : []
    content {
      path_pattern {
        values = each.value.paths
      }
    }
  }

  condition {
    http_header {
      http_header_name = var.custom_header.name
      values           = [var.custom_header.value]
    }
  }
}
