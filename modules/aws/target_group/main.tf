resource "aws_lb_target_group" "slack_metrics_api" {
  deregistration_delay              = "115"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "slack-metrics-api-${var.env}"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  slow_start                        = 0
  tags                              = {}
  target_type                       = "ip"
  vpc_id                            = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 10
    matcher             = "200"
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
      lambda_multi_value_headers_enabled,
      proxy_protocol_v2,
    ]
  }
}
