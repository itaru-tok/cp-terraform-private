output "name_slack_metrics_api" {
  value = aws_cloudwatch_log_group.slack_metrics_api.name
}

output "arn_slack_metrics_api" {
  value = aws_cloudwatch_log_group.slack_metrics_api.arn
}
