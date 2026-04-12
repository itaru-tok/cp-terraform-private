output "arn_db_main_instance" {
  value = aws_secretsmanager_secret.db_main_instance.arn
}

output "arn_db_slack_metrics_rds_proxy" {
  value = aws_secretsmanager_secret.db_slack_metrics_rds_proxy.arn
}
