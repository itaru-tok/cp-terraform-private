resource "aws_lb" "alb" {
  name               = "cp-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "403 forbidden"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "slack_metrics_api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = var.tg_slack_metrics_api_arn
  }

  condition {
    host_header {
      values = ["sm-api.${var.base_host}"]
    }
  }
}
