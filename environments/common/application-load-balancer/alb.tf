#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "application_load_balancer" {
  name               = "trade-tariff-application-loadbalancer-${var.environment}"
  load_balancer_type = "application"
  internal           = false

  vpc_id                           = var.public_vpc_id
  subnets                          = [var.public_subnets_id]
  security_groups                  = [var.alb_security_group_id]
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  drop_invalid_header_fields       = true


  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}

resource "aws_lb_target_group" "trade_trade_tariff_frontend_target_group" {
  name        = "trade_trade_tariff_frontend_target_group-${var.environment}"
  port        = var.application_port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = data.terraform_remote_state.base.outputs.public_subnets_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "trade_tariff_backend_target_group" {
  name        = "trade_tariff_backend_target_group-${var.environment}"
  port        = var.application_port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = data.terraform_remote_state.base.outputs.public_subnets_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "trade_tariff_trade_tariff_duty_cal_target_group" {
  name        = "trade_tariff_trade_tariff_duty_cal_target_group-${var.environment}"
  port        = var.application_port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = data.terraform_remote_state.base.outputs.public_subnets_id

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "trade_tariff_frontend_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.listening_port
  protocol          = var.protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trade_trade_tariff_frontend_target_group.arn
  }
}

resource "aws_lb_listener" "trade_tariff_backend_target_group" {
  load_balancer_arn = aws_lb.application_loadbalancer.arn
  port              = var.listening_port
  protocol          = var.protocol
  ssl_policy        = var.ssl_policy

  default_action {
    target_group_arn = aws_lb_target_group.trade_tariff_backend_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "trade_tariff_duty_cal" {
  load_balancer_arn = aws_lb.application_loadbalancer.arn
  port              = var.listening_port
  protocol          = var.protocol
  ssl_policy        = var.ssl_policy

  default_action {
    target_group_arn = aws_lb_target_group.trade_tariff_trade_tariff_duty_cal_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "https_cert_resource" {
  listener_arn    = aws_lb_listener.trade_tariff_frontend.arn
  certificate_arn = var.certificate_arn
}
