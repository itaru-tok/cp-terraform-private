output "arn_slack_metrics_api" {
  value = aws_lb_target_group.slack_metrics_api.arn
}

output "arn_cost_api" {
  value = aws_lb_target_group.cost_api.arn
}
