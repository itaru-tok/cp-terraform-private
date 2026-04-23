output "alarm_arn_server_error_slack_metrics_api" {
  value = aws_cloudwatch_metric_alarm.server_error_slack_metrics_api.arn
}

output "alarm_arn_rds_cpu_cloud_pratica" {
  value = aws_cloudwatch_metric_alarm.rds_cpu_cloud_pratica.arn
}
